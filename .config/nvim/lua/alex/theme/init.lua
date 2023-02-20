vim.opt.background = 'dark'

require 'alex.theme.onedark'

-- Enable colors in the terminal.
if vim.fn.has('termguicolors') then
    vim.cmd('set termguicolors')
end

-- Not too sure why this has to be here?
vim.cmd('let $TERM="alacritty"')

require 'alex.theme.nordic'
