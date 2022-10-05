--------------------------
-- General key bindings --
--------------------------

-- For key mappings for all modes.
local all_modes = { 'n', 'i', 'v', 't' }
local exclude_t = { 'n', 'i', 'v' }
local n_i = { 'n', 'i' }
local n = 'n'
local t = 't'

-- Function to map keys.
local map_key = vim.api.nvim_set_keymap
-- Default config for the keymaps.
local default_settings = {
    noremap = true,
    silent = true
}

-- Bufferline.
map_key(n, '<C-<>', '<Cmd>BufferLineMovePrev<CR>',  default_settings)
map_key(n, '<C->>', '<Cmd>BufferLineMoveNext<CR>',  default_settings)
map_key(n, '<C-,>', '<Cmd>BufferLineCyclePrev<CR>', default_settings)
map_key(n, '<C-.>', '<Cmd>BufferLineCycleNext<CR>', default_settings)
map_key(n, '<C-?>', '<Cmd>lua bdelete<CR>',         default_settings)
map_key(n, 'db',    '<Cmd>BufferLinePickClose<CR>', default_settings)
map_key(n, 'gb',    '<Cmd>BufferLinePick<CR>',      default_settings)

-- Search for files in current directory.
map_key(exclude_t, '<F3>', '<Cmd>Telescope find_files<CR>', default_settings)

-- Toggle the file explorer.
map_key(all_modes, '<F2>', '<Cmd>NvimTreeToggle<CR>', default_settings)

-- Grep for a string in the current directory.
map_key(exclude_t, '<F4>', '<Cmd>Telescope live_grep<CR>', default_settings)

-- Search for old files.
map_key(exclude_t, '<C-t>', '<Cmd>Telescope oldfiles<CR>', default_settings)

-- Cheatsheet.
map_key(all_modes, '<F12>', '<Cmd>Cheatsheet<CR>', default_settings)

-- Lazygit.
map_key(all_modes, '<C-g>', '<Cmd>LazyGit<CR>', default_settings)

-- Change lazygit repo.
map_key(all_modes, '<C-r>', '<Cmd>lua require("telescope").extensions.lazygit.lazygit()<CR>', default_settings)

-- Sessions.
map_key(n, '<F5>', '<Cmd>SSave<CR> " Saved current session.", "success", { title = " Session"} )<CR>', default_settings)

-- Moving windows.
map_key(n, '<C-h>','<Cmd>wincmd h<CR>', default_settings)
map_key(n, '<C-j>','<Cmd>wincmd j<CR>', default_settings)
map_key(n, '<C-k>','<Cmd>wincmd k<CR>', default_settings)
map_key(n, '<C-l>','<Cmd>wincmd l<CR>', default_settings)

-- Allow moving out of the terminal.
map_key(t, '<C-h>', '<Cmd>wincmd h<CR>', default_settings)
map_key(t, '<C-j>', '<Cmd>wincmd j<CR>', default_settings)
map_key(t, '<C-k>', '<Cmd>wincmd k<CR>', default_settings)
map_key(t, '<C-l>', '<Cmd>wincmd l<CR>', default_settings)

-- Commenting.
map_key(exclude_t, '<C-/>', '<Cmd>Commentary<CR>', default_settings)

-- Saving.
map_key(exclude_t, '<C-s>', '<Cmd>w!<CR>', default_settings)

-- Buffers.
map_key(all_modes, '<C-TAB>', '<Cmd>Telescope buffers<CR>', default_settings)

-- Finding.
map_key(n_i, '<C-f>', '<Cmd>Telescope current_buffer_fuzzy_find previewer=false<CR>', default_settings)

-- Disable the search highlight when hitting esc.
map_key(exclude_t, '<Esc>', '<Cmd>noh<CR>', default_settings)

-- Undo.
map_key(exclude_t, '<C-Z>', '<Cmd>undo<CR>', default_settings)

-- Redo.
map_key(exclude_t, '<C-Y>', '<Cmd>redo<CR>', default_settings)

-- Zen mode.
map_key(exclude_t, '<C-a>', '<Cmd>TZAtaraxis<CR>', default_settings)
