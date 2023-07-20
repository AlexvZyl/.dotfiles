local u = require 'alex.utils'

vim.cmd 'filetype plugin indent on'

-- Important to place this before loading plugins.
vim.g.mapleader = ' '

vim.cmd 'set noshowmode'
vim.cmd 'set clipboard+=unnamedplus'
vim.cmd 'set noswapfile'
vim.cmd 'set mouse=a'
vim.cmd 'set hlsearch'

vim.cmd 'set ignorecase'
vim.cmd 'set smartcase'

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.textwidth = 0

vim.cmd 'set expandtab'
vim.cmd 'set autoindent'
vim.cmd 'set smartindent'
vim.cmd 'set nowrap'

vim.opt.cmdheight = 0
vim.g.VM_set_statusline = 0
vim.g.VM_silent_exit = 1

vim.opt.fillchars = {
    horiz = u.bottom_thin,
    horizup = u.bottom_thin,
    horizdown = ' ',
    vert = ' ',
    vertleft = ' ',
    vertright = ' ',
    verthoriz = ' ',
    eob = ' ',
    diff = '╱',
}

vim.cmd 'set number'
vim.cmd 'set relativenumber'
vim.cmd 'set signcolumn=yes'

vim.cmd 'set cursorline'
-- vim.cmd 'set cursorlineopt=both'
vim.cmd 'set cursorlineopt=number'

vim.opt.winblend = 0

vim.opt.pumblend = 0
vim.opt.pumheight = 10

vim.opt.background = 'dark'

-- Default new window to vertical split.
-- Messes up debugger windows.
-- vim.cmd ':autocmd WinNew * wincmd H'
