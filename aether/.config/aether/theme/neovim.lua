return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#222235",
        dark_bg    = "#1a1a28",
        darker_bg  = "#11111b",
        lighter_bg = "#383849",

        fg         = "#B8B7CB",
        dark_fg    = "#8a8998",
        light_fg   = "#c3c2d3",
        bright_fg  = "#cac9d8",
        muted      = "#74747b",

        red        = "#b68588",
        yellow     = "#78956b",
        orange     = "#c1979a",
        green      = "#69977d",
        cyan       = "#70a8b1",
        blue       = "#8691bd",
        purple     = "#a588ab",
        brown      = "#745b5c",

        bright_red    = "#e1a8ac",
        bright_yellow = "#99bc84",
        bright_green  = "#89be9c",
        bright_cyan   = "#6bbbc7",
        bright_blue   = "#aab5ed",
        bright_purple = "#ba93c2",

        accent               = "#8691bd",
        cursor               = "#B8B7CB",
        foreground           = "#B8B7CB",
        background           = "#222235",
        selection             = "#383849",
        selection_foreground = "#B8B7CB",
        selection_background = "#383849",
      },
    },
    -- set up hot reload
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")
      require("aether.hotreload").setup()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
