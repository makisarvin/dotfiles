-- Treat .mdx files as a markdown variant so treesitter/render-markdown pick them up.
vim.filetype.add({ extension = { mdx = 'markdown.mdx' } })

return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ft = { 'markdown', 'markdown.mdx' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        file_types = { 'markdown', 'markdown.mdx' },
        latex = {
            enabled = true,
            converter = 'latex2text', -- requires: pip install pylatexenc
        },
    },
}
