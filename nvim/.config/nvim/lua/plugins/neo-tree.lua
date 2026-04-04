return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},

	lazy = false,

	opts = {
		filesystem = {
			filtered_items = {
				hide_gitignored = true,
			},
		},
	},
	config = function()
		require("neo-tree").setup({
			enable_git_status = true,
			open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
			filesystem = {
				filtered_items = {
					visible = false, -- when true, they will just be displayed differently than normal items
					hide_dotfiles = true,
					hide_gitignored = true,
					hide_ignored = true, -- hide files that are ignored by other gitignore-like files
					-- other gitignore-like files, in descending order of precedence.
					ignore_files = {
						".neotreeignore",
						".gitignore",
					},
					--always_show = { -- remains visible even if other settings would normally hide it
					--	".gitignore",
					--},
					always_show_by_pattern = { -- uses glob style patterns
						".env*",
					},
					never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
						".DS_Store",
						"thumbs.db",
					},
					never_show_by_pattern = { -- uses glob style patterns
						"vscode",
					},
				},
			},
		})

		vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", {})
		vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
	end,
}
