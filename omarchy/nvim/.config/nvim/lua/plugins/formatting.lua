return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason-org/mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    opts = {
      keys = {
	      {
        	"<leader>cF",
        	function()
          		require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        	end,
        	mode = { "n", "x" },
        	desc = "Format Injected Langs",
      	},
      },
    },
    config = function()
	    require("conform").setup({
	        default_format_opts = {
        	timeout_ms = 3000,
          	async = false, -- not recommended to change
          	quiet = false, -- not recommended to change
          	lsp_format = "fallback", -- not recommended to change
        },
        formatters_by_ft = {
          lua = { "stylua" },
	        python = { "isort", "black" },
	        javascript = { "prettierd", "prettier", stop_after_first = true },
	        typescript = { "prettierd", "prettier", stop_after_first = true },
	        java = { "google-java-format" },
        },
	      format_on_save = {
		      timeout_ms = 500,
		      lst_format = "fallback",
	      },
      })
    end,
  }
}
