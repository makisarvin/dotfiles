-- Treat .mdx files as a markdown variant so treesitter/render-markdown pick them up.
vim.filetype.add({ extension = { mdx = 'markdown.mdx' } })

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },            -- if you use the mini.nvim suite
  ft = { 'markdown', 'markdown.mdx' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    file_types = { 'markdown', 'markdown.mdx' },
    latex = {
      enabled = true,
      converter = 'latex2text', -- requires: pip install pylatexenc
    },
    checkbox = {
      enabled = true,
      unchecked = { icon = '󰄱 aaa ', highlight = 'RenderMarkdownUnchecked', scope_highlight = nil },
      checked = { icon = '󰱒 XX', highlight = 'RenderMarkdownChecked', scope_highlight = nil },
      custom = {
        todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
      },
    },
    html = {
      -- Turn on / off all HTML rendering
      enabled = true,
      comment = {
        -- Turn on / off HTML comment concealing
        conceal = false,
      },
    },
  },
}
