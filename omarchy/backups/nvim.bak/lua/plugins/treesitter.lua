return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, { "luau", "latex", "markdown", "markdown_inline", "yaml", "json" })
  end,
}
