local u = require 'alex.utils'

-- Do not show the current mode in cmdline.
vim.cmd 'set noshowmode'

-- Clipboard.
vim.cmd 'set clipboard+=unnamedplus'

vim.cmd 'set noswapfile'

-- Enable mouse input.
vim.cmd 'set mouse=a'

-- Keep the sign column open.
vim.cmd 'set signcolumn=yes'

-- Syntax.
vim.cmd 'set number'
vim.cmd 'set relativenumber'
vim.cmd 'set cursorline'
vim.cmd 'set cursorlineopt=number'
-- vim.cmd 'set cursorlineopt=both'
vim.cmd 'set hlsearch'
vim.cmd 'set ignorecase'
vim.cmd 'set smartcase'

-- Setup tabbing.
vim.cmd 'set tabstop	=4'
vim.cmd 'set softtabstop=4'
vim.cmd 'set shiftwidth =4'
vim.cmd 'set textwidth	=0'
vim.cmd 'set expandtab'
vim.cmd 'set autoindent'

-- Completion.
vim.cmd 'set completeopt=menu,menuone,noselect'

-- Disable text wrap around.
vim.cmd 'set nowrap'

-- Make the cmdline disappear when not in use.
vim.cmd 'set cmdheight=0'

-- Disable VM exit message and statusline.
vim.g.VM_set_statusline = 0
vim.g.VM_silent_exit = 1

-- Neovim fill characters.
vim.opt.fillchars = {
    horiz = u.bottom_thin,
    horizup = ' ',
    horizdown = ' ',
    vert = ' ',
    vertleft = ' ',
    vertright = ' ',
    verthoriz = ' ',
    eob = ' ',
    diff = '╱',
}

-- Set space as leader.
vim.g.mapleader = ' '

-- Change spell checking hl.
vim.cmd 'hi SpellBad gui=undercurl'

-- Windows and popups.
vim.cmd 'set winblend=0'
vim.cmd 'set pumblend=0'
vim.opt.pumheight = 10
