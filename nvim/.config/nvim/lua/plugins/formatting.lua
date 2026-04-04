return {
	{
		"stevearc/conform.nvim",
		opts = {},
		--   keys = {
		--     "<leader>cf",
		--     function()
		--       require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
		--     end,
		--     mode = { "n", "x" },
		--     description = "Format injected Languages",
		--   },
		--
	  config = function()
			require("conform").setup({
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
	},
}
