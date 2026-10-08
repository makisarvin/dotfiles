return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  event = "InsertEnter",
  config = function()
    local luasnip = require("luasnip")

    luasnip.setup({
      -- When opening a .luau file, also load all snippets from 'lua'
      -- (this immediately gives you all friendly-snippets lua loops/functions in luau)
      load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft({
        luau = { "lua" },
      }),
    })

    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Load custom snippets from ~/.config/nvim/snippets/
    require("luasnip.loaders.from_lua").lazy_load()
  end,
}
