return {
  {
    -- Autocompletion
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",

    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return nil
          end
          return "make install_jsregexp"
        end)(),
        opts = {},
      },
    },

    opts = {
      keymap = {
        preset = "default",
        ['<TAB>'] = { 'select_and_accept', 'fallback' },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 500,
        },
      },

      sources = {
        default = { "lsp", "path", "snippets" },
      },

      snippets = {
        preset = "luasnip",
      },

      fuzzy = {
        implementation = "lua",
      },

      signature = {
        enabled = true,
      },
    },
  },

  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    config = function()
      local opts = { 'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'lazy', 'mason' }
      require("ufo").setup({
        filetype_exclude = opts,
        provider_selector = function(bufnr, filetype, buftype)
          return {'treesitter', 'indent'}
        end
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('local_detach_ufo', { clear = true }),
        pattern = opts,
        callback = function()
          require('ufo').detach()
        end,
      })

      vim.opt.foldlevelstart = 99

  end
  }
}
