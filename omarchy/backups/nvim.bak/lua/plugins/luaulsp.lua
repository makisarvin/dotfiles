return {
  "lopi-py/luau-lsp.nvim",
  --    ft = "luau",

  init = function()
    vim.lsp.config("*", {
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
    })

    vim.lsp.config("luau-lsp", {
      settings = {
        ["luau-lsp"] = {
          completion = {
            autocompleteEnd = true,
          },
        },
      },
    })

    -- luau-lsp implements autocompleteEnd through a completion request whose
    -- trigger character is a newline. Send that request after inserting <CR>;
    -- blink.cmp does not reliably forward newline-triggered requests.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "luau",
      callback = function(event)
        vim.keymap.set("i", "<CR>", function()
          local bufnr = event.buf

          vim.defer_fn(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return
            end

            local client = vim.lsp.get_clients({ bufnr = bufnr, name = "luau-lsp" })[1]
            local winid = vim.fn.bufwinid(bufnr)
            if not client or winid == -1 then
              return
            end

            local params = vim.lsp.util.make_position_params(winid, client.offset_encoding)
            params.context = {
              triggerKind = vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter,
              triggerCharacter = "\n",
            }

            client:request("textDocument/completion", params, function() end, bufnr)
          end, 10)

          return "\r"
        end, { buffer = event.buf, expr = true, desc = "Newline with Luau block completion" })
      end,
    })
  end,

  opts = {
    platform = {
      type = "roblox",
    },

    fflags = {
      enable_new_solver = true,
      sync = true,
    },

    types = {
      roblox_security_level = "PluginSecurity",
    },

    sourcemap = {
      enabled = true,
      autogenerate = true,

      rojo_project_file = "default.project.json",
      sourcemap_file = "sourcemap.json",
    },

    plugin = {
      enabled = false,
      port = 3667,
    },
  },

  config = function(_, opts)
    require("luau-lsp").setup(opts)

    -- The plugin normally initializes the server from its first Luau FileType
    -- event. Because server setup is asynchronous, vim.lsp.enable() can miss
    -- that same event, leaving the first Luau buffer without an LSP client.
    -- Initialize eagerly instead so the client is ready before a file is opened.
    for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = "FileType", pattern = "luau" })) do
      if type(autocmd.callback) == "function" then
        local source = debug.getinfo(autocmd.callback, "S").source
        if source:find("/luau-lsp.nvim/plugin/luau-lsp.lua", 1, true) then
          vim.api.nvim_del_autocmd(autocmd.id)
        end
      end
    end

    require("luau-lsp.server").setup()
  end,
}
