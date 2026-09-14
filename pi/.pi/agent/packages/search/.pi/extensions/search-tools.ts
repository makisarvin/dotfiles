/// <reference types="node" />

/**
 * Search Tools Extension
 *
 * Registers fast, specialized search tools that leverage system-installed binaries:
 * - ripgrep_search: fast text/code search with ripgrep (rg)
 * - jq_query: JSON querying and filtering with jq
 * - ast_grep_cli: semantic code search with ast-grep (sg)
 *
 * The extension NEVER installs these tools. It checks at runtime and returns
 * clear "not installed" errors so the model falls back to read/bash/other tools.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { spawn } from "node:child_process";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function runCommand(
  cmd: string,
  args: string[],
  timeoutMs = 30000,
): Promise<{ stdout: string; stderr: string; exitCode: number }> {
  return new Promise((resolve) => {
    const child = spawn(cmd, args, { stdio: ["ignore", "pipe", "pipe"] });
    const outChunks: Buffer[] = [];
    const errChunks: Buffer[] = [];
    let killed = false;

    const timer = setTimeout(() => {
      killed = true;
      child.kill();
    }, timeoutMs);

    child.stdout.on("data", (data: Buffer) => outChunks.push(data));
    child.stderr.on("data", (data: Buffer) => errChunks.push(data));
    child.on("error", (err: NodeJS.ErrnoException) => {
      clearTimeout(timer);
      const msg = err.message;
      resolve({
        stdout: "",
        stderr: msg,
        exitCode: msg.includes("ENOENT") ? 127 : 1,
      });
    });
    child.on("close", (code: number | null) => {
      clearTimeout(timer);
      resolve({
        stdout: Buffer.concat(outChunks).toString("utf-8"),
        stderr: Buffer.concat(errChunks).toString("utf-8"),
        exitCode: killed ? 124 : (code ?? 1),
      });
    });
  });
}

function truncate(text: string, maxChars = 50_000): string {
  if (text.length <= maxChars) return text;
  return text.slice(0, maxChars) + "\n\n... [output truncated]";
}

// ---------------------------------------------------------------------------
// Tool: ripgrep_search
// ---------------------------------------------------------------------------

const ripgrepParams = Type.Object({
  query: Type.String({ description: "Regex or literal pattern to search for" }),
  paths: Type.Optional(
    Type.Array(
      Type.String({
        description:
          "Directories or files to search. Defaults to current working directory if omitted.",
      }),
    ),
  ),
  literal: Type.Optional(
    Type.Boolean({
      description: "Treat pattern as literal string instead of regex",
      default: false,
    }),
  ),
  caseSensitive: Type.Optional(
    Type.Boolean({ description: "Case-sensitive matching", default: true }),
  ),
  fileType: Type.Optional(
    Type.String({
      description:
        "Filter by file extension without dot, e.g. 'ts', 'js', 'md', 'py'",
    }),
  ),
  maxResults: Type.Optional(
    Type.Number({
      description: "Maximum number of matching lines to return",
      default: 100,
    }),
  ),
  contextLines: Type.Optional(
    Type.Number({
      description: "Lines of context around each match",
      default: 2,
    }),
  ),
  includeHidden: Type.Optional(
    Type.Boolean({
      description: "Search hidden files and directories",
      default: false,
    }),
  ),
});

function runRipgrep(params: Record<string, unknown>) {
  const args: string[] = ["--line-number"];

  if (params.literal) args.push("--fixed-strings");
  if (!params.caseSensitive) args.push("--ignore-case");
  if (params.fileType) args.push("--type", String(params.fileType));
  if (params.includeHidden) args.push("--hidden");
  if ((params.maxResults ?? 100) > 0)
    args.push("--max-count", String(params.maxResults));

  const ctx = (params.contextLines ?? 2) as number;
  if (ctx > 0) {
    args.push("-C", String(ctx));
  }

  args.push(String(params.query));

  const paths =
    Array.isArray(params.paths) && params.paths.length > 0
      ? params.paths.map(String)
      : ["."];
  args.push(...paths);

  return runCommand("rg", args, 30000);
}

function registerRipgrep(pi: ExtensionAPI) {
  pi.registerTool({
    name: "ripgrep_search",
    label: "Ripgrep Search",
    description:
      "Fast text/code search across files using ripgrep (rg). " +
      "Use this INSTEAD of read, symbol_search, or bash grep when you need to find text patterns across multiple files or large directories. " +
      "Much faster than reading files individually. Falls back gracefully if ripgrep is not installed.",
    parameters: ripgrepParams,
    async execute(_toolCallId: string, params: Record<string, unknown>) {
      const result = await runCommand("rg", ["--version"]);
      if (result.exitCode === 127) {
        return {
          content: [
            {
              type: "text",
              text: "Error: ripgrep (rg) is not installed on this system. Please use read, bash, or symbol_search instead.",
            },
          ],
          details: { available: false },
          isError: true,
        };
      }

      const searchResult = await runRipgrep(params);

      if (searchResult.exitCode !== 0 && searchResult.exitCode !== 1) {
        // exit code 1 from rg means "no matches", which is fine
        return {
          content: [
            {
              type: "text",
              text: `ripgrep error (exit ${searchResult.exitCode}):\n${searchResult.stderr}`,
            },
          ],
          details: {
            exitCode: searchResult.exitCode,
            stderr: searchResult.stderr,
          },
          isError: true,
        };
      }

      const output = searchResult.stdout || "(no matches)";
      return {
        content: [{ type: "text", text: truncate(output) }],
        details: {
          matched: searchResult.exitCode === 0,
          linesReturned: output.split("\n").length,
        },
      };
    },
  });
}

// ---------------------------------------------------------------------------
// Tool: jq_query
// ---------------------------------------------------------------------------

const jqParams = Type.Object({
  query: Type.String({
    description:
      "jq filter expression, e.g. '.packages[] | .name' or '.users[0].email'",
  }),
  filePath: Type.Optional(
    Type.String({
      description:
        "Path to a JSON file to query. Either filePath or jsonInput must be provided.",
    }),
  ),
  jsonInput: Type.Optional(
    Type.String({
      description:
        "Inline JSON string to query. Either filePath or jsonInput must be provided.",
    }),
  ),
  raw: Type.Optional(
    Type.Boolean({
      description: "Output raw strings instead of JSON",
      default: false,
    }),
  ),
});

function buildJqArgs(params: Record<string, unknown>): string[] {
  const args: string[] = [];
  if (params.raw) args.push("-r");
  args.push(String(params.query));
  if (params.filePath) args.push(String(params.filePath));
  return args;
}

function runJq(
  args: string[],
  input: string,
): Promise<{ stdout: string; stderr: string; exitCode: number }> {
  return new Promise((resolve) => {
    const child = spawn("jq", args, { stdio: ["pipe", "pipe", "pipe"] });
    const outChunks: Buffer[] = [];
    const errChunks: Buffer[] = [];

    child.stdout.on("data", (data: Buffer) => outChunks.push(data));
    child.stderr.on("data", (data: Buffer) => errChunks.push(data));

    if (input) {
      child.stdin.write(input, "utf-8");
      child.stdin.end();
    }

    const timer = setTimeout(() => child.kill(), 30000);
    child.on("error", (err: NodeJS.ErrnoException) => {
      clearTimeout(timer);
      resolve({ stdout: "", stderr: err.message, exitCode: 1 });
    });
    child.on("close", (code: number | null) => {
      clearTimeout(timer);
      resolve({
        stdout: Buffer.concat(outChunks).toString("utf-8"),
        stderr: Buffer.concat(errChunks).toString("utf-8"),
        exitCode: code ?? 1,
      });
    });
  });
}

function registerJq(pi: ExtensionAPI) {
  pi.registerTool({
    name: "jq_query",
    label: "JQ Query",
    description:
      "Query and filter JSON files using jq. " +
      "Use this INSTEAD of read when you need specific fields from JSON files, especially large ones. " +
      "Much more efficient than reading the entire file and manually extracting fields. " +
      "Falls back gracefully if jq is not installed.",
    parameters: jqParams,
    async execute(_toolCallId: string, params: Record<string, unknown>) {
      const check = await runCommand("jq", ["--version"]);
      if (check.exitCode === 127) {
        return {
          content: [
            {
              type: "text",
              text: "Error: jq is not installed on this system. Please use read or bash instead.",
            },
          ],
          details: { available: false },
          isError: true,
        };
      }

      if (!params.filePath && !params.jsonInput) {
        return {
          content: [
            {
              type: "text",
              text: "Error: either filePath or jsonInput must be provided.",
            },
          ],
          isError: true,
        };
      }

      const args = buildJqArgs(params);
      const input = params.jsonInput ? String(params.jsonInput) : "";

      const jqResult = await runJq(args, input);

      if (jqResult.exitCode !== 0) {
        return {
          content: [
            {
              type: "text",
              text: `jq error (exit ${jqResult.exitCode}):\n${jqResult.stderr}`,
            },
          ],
          details: { exitCode: jqResult.exitCode, stderr: jqResult.stderr },
          isError: true,
        };
      }

      return {
        content: [
          { type: "text", text: truncate(jqResult.stdout || "(no output)") },
        ],
        details: { exitCode: jqResult.exitCode },
      };
    },
  });
}

// ---------------------------------------------------------------------------
// Tool: ast_grep_cli
// ---------------------------------------------------------------------------

const astgrepParams = Type.Object({
  pattern: Type.String({
    description:
      "ast-grep pattern (e.g., 'console.log($A)', 'function $NAME($$$ARGS) { $$$BODY }')",
  }),
  paths: Type.Optional(
    Type.Array(
      Type.String({
        description:
          "Directories or files to search. Defaults to current working directory if omitted.",
      }),
    ),
  ),
  lang: Type.Optional(
    Type.String({
      description:
        "Language identifier, e.g. 'typescript', 'javascript', 'python', 'go', 'rust', 'java'",
    }),
  ),
  maxResults: Type.Optional(
    Type.Number({ description: "Maximum matches to return", default: 50 }),
  ),
  rewrite: Type.Optional(
    Type.String({
      description:
        "Rewrite pattern to apply (optional). Use only when you want to preview a transformation.",
    }),
  ),
});

function runAstgrep(params: Record<string, unknown>, binary: string) {
  const args: string[] = ["run"];
  args.push("-p", String(params.pattern));

  if (params.lang) args.push("-l", String(params.lang));
  if (params.rewrite) args.push("-r", String(params.rewrite));

  const paths =
    Array.isArray(params.paths) && params.paths.length > 0
      ? params.paths.map(String)
      : ["."];
  args.push(...paths);

  return runCommand(binary, args, 30000);
}

function registerAstGrep(pi: ExtensionAPI) {
  pi.registerTool({
    name: "ast_grep_cli",
    label: "ast-grep CLI",
    description:
      "Semantic code search using ast-grep (sg). Searches code by abstract syntax tree (AST) patterns rather than plain text. " +
      "Use this INSTEAD of ripgrep_search or symbol_search when you need language-specific constructs (e.g., 'all function definitions named X', 'all class declarations with async methods'). " +
      "Much more precise than text search for code patterns. Falls back gracefully if ast-grep is not installed.",
    parameters: astgrepParams,
    async execute(_toolCallId: string, params: Record<string, unknown>) {
      // Try 'sg' first, then 'ast-grep'
      let binary = "sg";
      let check = await runCommand(binary, ["--version"]);
      if (check.exitCode === 127) {
        binary = "ast-grep";
        check = await runCommand(binary, ["--version"]);
        if (check.exitCode === 127) {
          return {
            content: [
              {
                type: "text",
                text: "Error: ast-grep (sg or ast-grep) is not installed on this system. Please use ripgrep_search, symbol_search, or bash instead.",
              },
            ],
            details: { available: false },
            isError: true,
          };
        }
      }

      const result = await runAstgrep(params, binary);

      if (result.exitCode !== 0 && result.exitCode !== 1) {
        return {
          content: [
            {
              type: "text",
              text: `ast-grep error (exit ${result.exitCode}):\n${result.stderr}`,
            },
          ],
          details: { exitCode: result.exitCode, stderr: result.stderr },
          isError: true,
        };
      }

      // Truncate to maxResults lines roughly
      let output = result.stdout || "(no matches)";
      const lines = output.split("\n");
      const max = (params.maxResults ?? 50) as number;
      if (lines.length > max) {
        output =
          lines.slice(0, max).join("\n") +
          `\n\n... [${lines.length - max} more matches truncated]`;
      }

      return {
        content: [{ type: "text", text: truncate(output, 50_000) }],
        details: { matched: result.exitCode === 0, totalLines: lines.length },
      };
    },
  });
}

// ---------------------------------------------------------------------------
// Extension entrypoint
// ---------------------------------------------------------------------------

export default function searchToolsExtension(pi: ExtensionAPI) {
  registerRipgrep(pi);
  registerJq(pi);
  registerAstGrep(pi);
}
