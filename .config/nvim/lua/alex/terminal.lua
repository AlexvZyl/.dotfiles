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

----------------------
-- Setup toggleterm --
----------------------

require 'toggleterm'.setup {
    on_open = function(term)
        vim.cmd("startinsert")
    end,
    direction = "float",
    size = 15,
    float_opts = {
        border = 'single',
        winblend = 0,
    }
}

----------------------------
-- BTop++ with toggleterm --
----------------------------

local Terminal  = require('toggleterm.terminal').Terminal
-- local btop = Terminal:new({ cmd = "btop --utf-force", hidden = true, direction = "float" })
local btop = Terminal:new({ cmd = "btop", hidden = true, direction = "float" })
-- local btop = Terminal:new({ cmd = "btm", hidden = true, direction = "float" })
function _btop_toggle()
  btop:toggle()
end
vim.api.nvim_set_keymap("n", "<C-B>", "<Cmd>lua _btop_toggle()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("t", "<C-B>", "<Cmd>lua _btop_toggle()<CR>", {noremap = true, silent = true})

--------------------------
-- Fish with toggleterm --
--------------------------

local Terminal  = require('toggleterm.terminal').Terminal
local fish = Terminal:new({ cmd = "fish", hidden = true, direction = "horizontal" })
function _fish_toggle()
  fish:toggle()
end
vim.api.nvim_set_keymap("n", "<F1>", "<Cmd>lua _fish_toggle()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("t", "<F1>", "<Cmd>lua _fish_toggle()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("v", "<F1>", "<Cmd>lua _fish_toggle()<CR>", {noremap = true, silent = true})
