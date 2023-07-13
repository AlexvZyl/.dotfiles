local u = require 'alex.utils'

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

vim.cmd 'set number'
vim.cmd 'set relativenumber'
vim.cmd 'set signcolumn=yes'

vim.cmd 'set cursorline'
-- vim.cmd 'set cursorlineopt=both'
vim.cmd 'set cursorlineopt=number'

vim.opt.winblend = 0

-- Modules
require 'alex.ui.tree'
require 'alex.ui.git'
require 'alex.ui.lualine'
require 'alex.ui.components'
require 'alex.ui.bufferline'
require 'alex.ui.dashboard'
require 'alex.ui.telescope'
require 'alex.ui.statuscolumn'
