vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- set leader to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- auto format
vim.g.autoformat = true
vim.o.autoread = true -- auto-reload changes outside of nvim

-- set to true if you have nerd font installed
vim.g.have_nerd_font = true

-- make line numbers default
vim.o.number = true
vim.wo.number = true
-- enable mouse mode
vim.o.mouse = "a"

-- enable undo/redo
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end

vim.o.undofile = true
vim.o.undodir = undodir


-- -----------------------------------
--Search Options
-- -----------------------------------
vim.o.ignorecase = true -- case insensitive search
vim.o.smartcase = true -- case sensitive if uppercase in string
vim.o.hlsearch = true -- highlight search matches
vim.o.incsearch = true -- show matches as you type

-- -----------------------------------
-- Editor view & panels
-- -----------------------------------
vim.o.signcolumn = "yes" -- always show sign column
vim.o.colorcolumn = "100" -- show a column at 100 position chars

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

-- Ensure termguicolors is enabled if not alrea
vim.opt.termguicolors = true

-- Configuration for folds
--vim.opt.foldlevel = 99
--vim.opt.foldmethod = "ident"
--vim.opt.foldtext = ""

