return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets', { 'L3MON4D3/LuaSnip', version = 'v2.*' } },

  version = '1.*',

  opts = {
    keymap = { preset = 'super-tab' },

    snippets = { preset = 'luasnip' },

    -- optional but nice with super-tab: don't force the menu open
    -- while jumping through snippet placeholders
    completion = {
      list = {
        selection = {
          preselect = function(_)
            return not require('blink.cmp').snippet_active({ direction = 1 })
          end,
        },
      },
    },

    appearance = {
      use_nvim_cmp_as_default = true,
    }
  },
}
