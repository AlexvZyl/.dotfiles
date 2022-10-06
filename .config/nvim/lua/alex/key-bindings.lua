-- I want to keep all of the key bindings in one file so that it is easy to see
-- what is being used and ensure nothing being overwritten by accident.

--------------------------
-- General key bindings --
--------------------------

-- For key mappings for all modes.
local all_modes = { 'n', 'i', 'v', 't' }
local exclude_t = { 'n', 'i', 'v' }
local n_v = { 'n', 'v' }
local n = 'n'
local t = 't'

-- Function to map keys.
local map_key = vim.keymap.set
-- Default config for the keymaps.
local default_settings = {
    noremap = true,
    silent = true,
}

-- Bufferline.
Close_current_buffer = require 'alex.ui.bufferline'.close_current_buffer_LV
map_key(n, '<C-<>', '<Cmd>BufferLineMovePrev<CR>',  default_settings)
map_key(n, '<C->>', '<Cmd>BufferLineMoveNext<CR>',  default_settings)
map_key(n, '<C-,>', '<Cmd>BufferLineCyclePrev<CR>', default_settings)
map_key(n, '<C-.>', '<Cmd>BufferLineCycleNext<CR>', default_settings)
map_key(n, '<C-q>', '<Cmd>lua Close_current_buffer()<CR>', default_settings)
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
map_key(exclude_t, '<C-TAB>', '<Cmd>Telescope buffers<CR>', default_settings)

-- Finding.
map_key(exclude_t, '<C-f>', '<Cmd>Telescope current_buffer_fuzzy_find previewer=false<CR>', default_settings)

-- Disable the search highlight when hitting esc.
-- map_key(all_modes, '<Esc>', '<Cmd>noh<CR>', { noremap = false })

-- Undo.
map_key(exclude_t, '<C-Z>', '<Cmd>undo<CR>', default_settings)

-- Redo.
map_key(exclude_t, '<C-Y>', '<Cmd>redo<CR>', default_settings)

-- Zen mode.
map_key(all_modes, '<C-a>', '<Cmd>TZAtaraxis<CR>', default_settings)

--------------
-- LSP Saga --
--------------

-- Go to reference (also shows definition).
map_key(n, "gr", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })

-- Code action
map_key(n_v, "ca", "<cmd>Lspsaga code_action<CR>", { silent = true })

-- Rename
map_key(n_v, "rr", "<cmd>Lspsaga rename<CR>", { silent = true })

-- Peek Definition
-- you can edit the definition file in this flaotwindow
-- also support open/vsplit/etc operation check definition_action_keys
-- support tagstack C-t jump back
map_key(n, "gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true })

-- Show docs.
map_key(n, "gD", "<cmd>Lspsaga hover_doc<CR>", { silent = true })

-- Show line diagnostics
map_key(n, "L", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })

-- Diagnsotic jump can use `<c-o>` to jump back
map_key(n, "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })
map_key(n, "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })

-- Only jump to error
map_key(n, "[E", function()
  require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { silent = true })
map_key(n, "]E", function()
  require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { silent = true })

-- Outline
map_key(exclude_t,"<leader>o", "<cmd>LSoutlineToggle<CR>",{ silent = true })
