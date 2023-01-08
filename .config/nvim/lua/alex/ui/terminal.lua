--------------------------------
-- Terminal emulator settings --
--------------------------------

-- Ensure we are in normal mode when leaving the terminal.
vim.cmd([[
    augroup LeavingTerminal
    autocmd! 
    autocmd TermLeave <silent> <Esc>
    augroup end
]])

-- Terminal mappings.
vim.cmd([[
    au BufEnter * if &buftype == 'terminal' | :startinsert | endif " Make terminal default mode insert mode.
    tnoremap <silent> <Esc> <C-\><C-n>
]])

-- Remove the padding in a terminal.
vim.cmd('autocmd TermOpen * setlocal signcolumn=no')

----------------
-- Toggleterm --
----------------

require 'toggleterm'.setup {
    on_open = function(_)
        vim.cmd("startinsert")
    end,
    direction = "float",
    size = 15,
    float_opts = {
        border = 'rounded',
        -- winblend = -1,
    }
}
