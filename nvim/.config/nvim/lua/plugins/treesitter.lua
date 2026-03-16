return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            local config = require("nvim-treesitter.config")
            config.setup({
                ensure_installed = {"lua", "luau", "javascript", "typescript", "python"},
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    }
}