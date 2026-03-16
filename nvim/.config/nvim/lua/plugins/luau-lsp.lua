return {
  {
    "lopi-py/luau-lsp.nvim",
    config = function()
      require("luau-lsp").setup({
        platform = {
          type = "roblox",
        },
        types = {
          roblox_security_level = "PluginSecurity"
        },
        sourcemap = {
          enabled = true,
          autogenerate = true, -- automatic generation when the server is initialized
          rojo_project_file = "default.project.json",
          sourcemap_file = "sourcemap.json",
        },
      })

      vim.lsp.config("*", {
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },
      })
    end
  }
}
