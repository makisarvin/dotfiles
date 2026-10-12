return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            local config = require("nvim-treesitter.config")
            config.setup({
                ensure_installed = {
			"lua", 
			"luau", 
			"javascript", 
			"typescript", 
			"python",
			"bash",
			"diff",
			"html",
			"latex",
			"json",
			"markdown",
			"markdown_inline",
			"regex",
			"toml",
			"tsx",
			"vim",
			"xml",
			"yaml",
		},
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    }
}
