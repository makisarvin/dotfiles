---
name: project-configure
description: Configure a local project for a specific type of work by copying plugins, extensions, and skills from a profiles directory. Use when the user wants to set up a project with pi packages, skills, or settings from a predefined profile (e.g., 'configure this project for luau', 'setup architecture tools', 'add web search to this project'). Supports single-source profiles, multi-source composites, and language-specific configurations.
---

# Project Configure

Configure the current project for a specific type of work by applying predefined pi settings, packages, and skills from a profile repository.

## How It Works

1. Reads `profiles.json` from the profiles directory (default: `~/.pi/agent/packages/`)
2. Resolves the requested profile to one or more source directories
3. **Automatically prepends the `common` profile as a base layer**
4. Merges all source `.pi/` configurations into the current project's `.pi/` directory

A profile can reference:
- **A single source** (`sourceDir`): simple profile that copies one `.pi/` folder
- **Multiple sources** (`sourceDirs`): composite profile that merges several `.pi/` folders
- **A language config** (`config`): points to a JSON file inside `languages/<lang>/` that defines `sourceDirs`

## Configuration

Set `PI_PROFILES_DIR` environment variable to point to your profiles repository:
```bash
export PI_PROFILES_DIR=/path/to/your/pi/packages
```

Default is `~/.pi/agent/packages`.

### profiles.json Format

```json
{
  "coding": {
    "sourceDir": "coding",
    "description": "General software development"
  },
  "architecture": {
    "sourceDirs": ["coding", "context", "search"],
    "description": "Architecture planning (no language-specific skills)"
  },
  "luau": {
    "config": "languages/luau/profile.json",
    "description": "Luau/Roblox development"
  }
}
```

| Field | Description |
|-------|-------------|
| `sourceDir` | Single directory containing a `.pi/` folder (backward-compatible) |
| `sourceDirs` | Array of directories, each with a `.pi/` folder, merged in order |
| `config` | Path to another JSON file (relative to profiles dir) that defines `sourceDirs` |
| `description` | Shown in the profile list |

### Language profiles

Language configs live in `languages/<lang>/profile.json`:

```json
{
  "sourceDirs": ["coding", "search", "languages/luau"],
  "description": "Luau/Roblox with strict typing, rojo, pesde, rokit"
}
```

This lets you compose base tooling (coding + search) with language-specific skills and extensions (languages/luau).

## Usage

### Configure current project

```bash
# Run the configure script for a profile
~/.pi/agent/skills/project-configure/scripts/configure.sh <profile-name>

# Or with a custom target directory
./scripts/configure.sh luau /path/to/project
```

### Using the skill in conversation

Just ask: *"configure this project for luau"* or *"setup architecture tools for this project"*.

The skill will:
1. Determine the target directory (current working directory)
2. Read the profiles configuration
3. Resolve the profile to its source directories
4. Run the configure script to merge all sources

## Merging Behavior

When a profile has multiple sources (or you apply multiple profiles over time), all configured sources are merged together. In addition, the **`common` profile is always automatically included** as the base layer for every profile except `common` itself.

### settings.json
- The `common` profile's `settings.json` is always included first, then all other source `settings.json` files are merged **before** being applied to the target
- Arrays (`packages`, `skills`, `extensions`) are combined across all sources and deduplicated
- Scalar fields: first non-null value wins (earlier sources take precedence — so `common` provides defaults, and later profiles can override)
- Then the combined result is merged into the target's existing `settings.json`, with target values taking precedence for scalars
- A backup is saved as `settings.json.bak`

### Directories
- `npm/`: copied from the **first** source that has it (if target doesn't already have one)
- `skills/`: merged — skills from all sources are copied; existing skills are never overwritten
- `extensions/`: merged — extensions from all sources are copied; existing extensions are never overwritten
- Other files/directories: copied from each source if not already present in target

## Examples

### Language development (Luau)

```bash
configure.sh luau
```

Applies:
- **`common/.pi/` → pi-hypa, pi-observational-memory (always included)**
- `coding/.pi/` → web access, code intelligence
- `search/.pi/` → ripgrep, jq, ast-grep search tools
- `languages/luau/.pi/` → luau-roblox skill

### Architecture planning

```bash
configure.sh architecture
```

Applies:
- **`common/.pi/` → pi-hypa, pi-observational-memory (always included)**
- `coding/.pi/` → web access, code intelligence
- `context/.pi/` → ask-user-question, todo, pi-rlm
- `search/.pi/` → search tools extension

No language-specific skills are added.

## Troubleshooting

- **Profile not found**: Check `profiles.json` exists in `$PI_PROFILES_DIR`
- **Config file not found**: Verify the `config` path is relative to `$PI_PROFILES_DIR`
- **No packages installed after configuration**: Restart pi in the target directory; it will auto-install packages listed in `settings.json`
- **Merge conflicts**: Check `.pi/settings.json.bak` to restore the previous configuration
- **Source directory missing `.pi/`**: The script skips it with a warning. Some directories (like `languages/<lang>/`) may only contain `skills/` without a `.pi/` folder — these are handled automatically
