return {

  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      automatic_enable = {
        exclude = { "luau_lsp" },
      },
      ensure_installed = { "luau_lsp" }
    },
  },
}
