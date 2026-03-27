vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- set to true if you have nerd font installed
vim.g.have_nerd_font = true

-- make line numbers default
vim.o.number = true

-- enable mouse mode
vim.o.mouse = 'a'

-- enable undo/redo
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

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

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>', {desc = "Move focus to the upper window"})
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>', {desc = "Move focus to the lower window"})
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>', {desc = "Move focus to the left window"})
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>', {desc = "Move focus to the right window"})


vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic window" })

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.wo.number = true


-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

