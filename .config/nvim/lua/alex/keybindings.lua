-- All of the general key bindings.

-- Function to map keys.
local map = vim.api.nvim_set_keymap
-- Default config for the keymaps.
local default_settings = {
    noremap = true,
    silent = true
}

-- Bufferline.
map('n', '<C-<>', '<Cmd>BufferLineMovePrev<CR>',  default_settings)
map('n', '<C->>', '<Cmd>BufferLineMoveNext<CR>',  default_settings)
map('n', '<C-,>', '<Cmd>BufferLineCyclePrev<CR>', default_settings)
map('n', '<C-.>', '<Cmd>BufferLineCycleNext<CR>', default_settings)
map('n', '<C-?>', '<Cmd>lua bdelete<CR>',         default_settings)
map('n', 'db',    '<Cmd>BufferLinePickClose<CR>', default_settings)
map('n', 'gb',    '<Cmd>BufferLinePick<CR>',      default_settings)

-- Search for files in current directory.
map('n', '<F3>', '<Cmd>Telescope find_files<CR>', default_settings)
map('i', '<F3>', '<Cmd>Telescope find_files<CR>', default_settings)
map('v', '<F3>', '<Cmd>Telescope find_files<CR>', default_settings)
map('t', '<F3>', '<Cmd>Telescope find_files<CR>', default_settings)

-- Toggle the file explorer.
map('n', '<F2>', '<Cmd>NvimTreeToggle<CR>', default_settings)
map('i', '<F2>', '<Cmd>NvimTreeToggle<CR>', default_settings)
map('v', '<F2>', '<Cmd>NvimTreeToggle<CR>', default_settings)
map('t', '<F2>', '<Cmd>NvimTreeToggle<CR>', default_settings)

-- Grep for a string in the current directory.
map('n', '<F4>', '<Cmd>Telescope live_grep<CR>', default_settings)
map('i', '<F4>', '<Cmd>Telescope live_grep<CR>', default_settings)
map('v', '<F4>', '<Cmd>Telescope live_grep<CR>', default_settings)
map('t', '<F4>', '<Cmd>Telescope live_grep<CR>', default_settings)

-- Search for old files.
map('n', '<C-t>', '<Cmd>Telescope oldfiles<CR>', default_settings)
map('i', '<C-t>', '<Cmd>Telescope oldfiles<CR>', default_settings)
map('v', '<C-t>', '<Cmd>Telescope oldfiles<CR>', default_settings)
map('t', '<C-t>', '<Cmd>Telescope oldfiles<CR>', default_settings)

-- Cheatsheet.
map('n', '<F12>', '<Cmd>Cheatsheet<CR>', default_settings)
map('i', '<F12>', '<Cmd>Cheatsheet<CR>', default_settings)
map('v', '<F12>', '<Cmd>Cheatsheet<CR>', default_settings)
map('t', '<F12>', '<Cmd>Cheatsheet<CR>', default_settings)

-- Lazygit.
map('n', '<C-g>', '<Cmd>LazyGit<CR>', default_settings)
map('i', '<C-g>', '<Cmd>LazyGit<CR>', default_settings)
map('v', '<C-g>', '<Cmd>LazyGit<CR>', default_settings)
map('t', '<C-g>', '<Cmd>LazyGit<CR>', default_settings)

-- Change lazygit repo.
map('n', '<C-r>', '<Cmd>lua require("telescope").extensions.lazygit.lazygit()<CR>', default_settings)
map('i', '<C-r>', '<Cmd>lua require("telescope").extensions.lazygit.lazygit()<CR>', default_settings)
map('v', '<C-r>', '<Cmd>lua require("telescope").extensions.lazygit.lazygit()<CR>', default_settings)
map('t', '<C-r>', '<Cmd>lua require("telescope").extensions.lazygit.lazygit()<CR>', default_settings)

-- Sessions.
map('n', '<F5>', '<Cmd>SSave<CR> " Saved current session.", "success", { title = " Session"} )<CR>', default_settings)

-- Moving windows.
map('n', '<C-h>','<Cmd>wincmd h<CR>', default_settings)
map('n', '<C-j>','<Cmd>wincmd j<CR>', default_settings)
map('n', '<C-k>','<Cmd>wincmd k<CR>', default_settings)
map('n', '<C-l>','<Cmd>wincmd l<CR>', default_settings)
-- Allow moving out of the terminal.
map('t', '<C-h>', '<Cmd>wincmd h<CR>', default_settings)
map('t', '<C-j>', '<Cmd>wincmd j<CR>', default_settings)
map('t', '<C-k>', '<Cmd>wincmd k<CR>', default_settings)
map('t', '<C-l>', '<Cmd>wincmd l<CR>', default_settings)

-- Commenting.
map('n', '<C-/>', '<Cmd>Commentary<CR>', default_settings)
map('i', '<C-/>', '<Cmd>Commentary<CR>', default_settings)
map('v', '<C-/>', '<Cmd>Commentary<CR>', default_settings)

-- Saving.
map('n', '<C-s>', '<Cmd>w!<CR>', default_settings)
map('v', '<C-s>', '<Cmd>w!<CR>', default_settings)
map('i', '<C-s>', '<Cmd>w!<CR>', default_settings)

-- Buffers.
map('n', '<C-TAB>', '<Cmd>Telescope buffers<CR>', default_settings)
map('i', '<C-TAB>', '<Cmd>Telescope buffers<CR>', default_settings)
map('t', '<C-TAB>', '<Cmd>Telescope buffers<CR>', default_settings)
map('v', '<C-TAB>', '<Cmd>Telescope buffers<CR>', default_settings)

-- Finding.
map('n', '<C-f>', '<Cmd>Telescope current_buffer_fuzzy_find previewer=false<CR>', default_settings)
map('i', '<C-f>', '<Cmd>Telescope current_buffer_fuzzy_find previewer=false<CR>', default_settings)

-- Disable the search highlight when hitting esc.
map('n', '<Esc>', '<Cmd>noh<CR>', default_settings)
map('i', '<Esc>', '<Cmd>stopinsert<CR> <Cmd>noh<CR>', default_settings)
map('v', '<Esc>', '<Cmd>noh<CR>', default_settings)

-- Undo.
map('n', '<C-Z>', '<Cmd>undo<CR>', default_settings)
map('i', '<C-Z>', '<Cmd>undo<CR>', default_settings)
-- Redo.
map('v', '<C-Z>', '<Cmd>undo<CR>', default_settings)
map('n', '<C-Y>', '<Cmd>redo<CR>', default_settings)
map('i', '<C-Y>', '<Cmd>redo<CR>', default_settings)
map('v', '<C-Y>', '<Cmd>redo<CR>', default_settings)

-- Zen mode.
map('n', '<C-a>', '<Cmd>TZAtaraxis<CR>', default_settings)
map('v', '<C-a>', '<Cmd>TZAtaraxis<CR>', default_settings)
map('i', '<C-a>', '<Cmd>TZAtaraxis<CR>', default_settings)
