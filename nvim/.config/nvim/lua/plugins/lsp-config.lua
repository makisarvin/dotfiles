return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "html",
        "cssls",
        "ts_ls",
        "pyright",
      },
      automatic_enable = {
        exclude = { "luau_lsp" }
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local on_attach = function(_, bufnr)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Goto Definition" })
        vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Goto Implementation" })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Goto References" })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code Action" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      vim.lsp.config("lua_ls", {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      vim.lsp.config("html", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      vim.lsp.config("cssls", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      vim.lsp.config("ts_ls", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      vim.lsp.config("pyright", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

    end,
  },

  {
    "j-hui/fidget.nvim",
    opts = {},
  },
}
