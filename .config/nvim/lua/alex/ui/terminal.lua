local u = require 'alex.utils'

-- Ensure we are in normal mode when leaving the terminal.
vim.cmd [[
    augroup LeavingTerminal
    autocmd! 
    autocmd TermLeave <silent> <Esc>
    augroup end
]]

-- Terminal mappings.
vim.cmd [[
    " Make terminal default mode insert mode.
    au BufEnter * if &buftype == 'terminal' | :startinsert | endif 
    " Go to normal mode when pressing escape in the terminal.
    tnoremap <silent> <Esc> <C-\><C-n>
]]

-- Setup environment.
if vim.fn.has 'termguicolors' then vim.cmd 'set termguicolors' end
vim.env.COLORTERM = 'xterm-256color'
vim.env.TERM = 'xterm-256color'
vim.env.TERMINAL = 'xterm-256color'
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

-- Used to toggle fullscreen terminal.
require('toggleterm').setup {
    on_open = function(_) vim.cmd 'startinsert' end,
    direction = 'float',
    float_opts = {
        border = u.border_chars_empty,
        width = function() return vim.o.columns end,
        height = function() return vim.o.lines end,
    },
}
