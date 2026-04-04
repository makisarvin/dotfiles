vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- auto format
vim.g.autoformat = true

-- set to true if you have nerd font installed
vim.g.have_nerd_font = true

-- make line numbers default
vim.o.number = true
vim.wo.number = true
-- enable mouse mode
vim.o.mouse = "a"

-- enable undo/redo
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

vim.opt.swapfile = false
vim.opt.clipboard = "unnamedplus"

-- Ensure termguicolors is enabled if not already
vim.opt.termguicolors = true

-- Configuration for folds
--vim.opt.foldlevel = 99
--vim.opt.foldmethod = "ident"
--vim.opt.foldtext = ""

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Navigate vim panes better
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>", { desc = "Move focus to the right window" })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic window" })

vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")
