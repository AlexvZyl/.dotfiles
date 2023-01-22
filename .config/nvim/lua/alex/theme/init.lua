vim.opt.background = 'dark'

-- Enable colors in the terminal.
if vim.fn.has('termguicolors') then
    vim.cmd('set termguicolors')
end

-- Not too sure why this has to be here?
vim.cmd('let $TERM="alacritty"')

-- Disable the cursorline when a window is not focused.
-- Keep the number highlight.
vim.cmd([[
    augroup CursorLine
        au!
        au VimEnter * setlocal cursorlineopt=both
        au WinEnter * setlocal cursorlineopt=both
        au BufWinEnter * setlocal cursorlineopt=both
        au WinLeave * setlocal cursorlineopt=number
    augroup END
]])

-- Load the scheme.
vim.cmd [[colorscheme nordic]]
