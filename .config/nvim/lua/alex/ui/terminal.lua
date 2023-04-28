local p = require 'nordic.colors'
local u = require 'alex.utils'

--------------------------------
-- Terminal emulator settings --
--------------------------------

-- Ensure we are in normal mode when leaving the terminal.
vim.cmd [[
    augroup LeavingTerminal
    autocmd! 
    autocmd TermLeave <silent> <Esc>
    augroup end
]]

-- Terminal mappings.
vim.cmd [[
    au BufEnter * if &buftype == 'terminal' | :startinsert | endif " Make terminal default mode insert mode.
    tnoremap <silent> <Esc> <C-\><C-n>
]]

-- Remove the padding in a terminal.
vim.cmd 'autocmd TermOpen * setlocal signcolumn=no'

----------------
-- Toggleterm --
----------------

function _Term_width()
    return vim.o.columns
end

function _Term_height()
    return vim.o.lines - 3
end

require('toggleterm').setup {
    on_open = function(_)
        vim.cmd 'startinsert'
    end,
    direction = 'float',
    float_opts = {
        -- border = 'curved',
        border = u.border_chars_outer_thin,
        width = _Term_width,
        height = _Term_height,
    },
    highlights = {
        FloatBorder = {
            guifg = p.bg_dark,
        },
    },
}
