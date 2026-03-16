return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    name = "which-key",

    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },

      spec = {
        { "C-s", group = "[S]earch", mode = { "n", "v" } },
        { "C-t", group = "[T]oggle" },
        { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        { "gr", group = "LSP Actions", mode = { "n" } },
      },
    },

    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  }
}
