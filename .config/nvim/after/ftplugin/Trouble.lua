local p = require 'nordic.colors'
local u = require 'alex.utils'

vim.wo.statuscolumn = ' '
vim.cmd 'set nocursorline '
vim.cmd('setlocal fillchars+=horiz:' .. u.bottom_thin )

