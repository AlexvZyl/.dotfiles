-- I want to keep all of the key bindings in one file so that it is easy to see
-- what is being used and ensure nothing being overwritten by accident.

--------------------------
-- General key bindings --
--------------------------

-- For key mappings for all modes.
local all_modes = { 'n', 'i', 'v', 't' }
local exclude_t = { 'n', 'i', 'v' }
local exclude_i  = { 'n', 'v', 't' }
local n_v = { 'n', 'v' }
local n_t = { 'n', 't' }
local n = 'n'

-- Function to map keys.
local map_key = vim.keymap.set
-- Default config for the keymaps.
local default_settings = {
    noremap = true,
    silent = true,
}

-- Sometimes I do not lift the ctrl key when trying to close a window.
-- Why does this not work?
map_key(n, '<C-w><C-c>', '<Cmd>wincmd c<CR>', default_settings)

-- Search for files in current directory.
map_key(exclude_t, '<F3>', '<Cmd>Telescope find_files<CR>', default_settings)

-- Toggle the file explorer.
function toggle_nvim_tree()
    require("nvim-tree.api").tree.toggle({})
    local is_open = require("nvim-tree.view").is_visible()
    if is_open then vim.wo.statuscolumn = ' ' end
end
map_key(all_modes, '<F2>', '<Cmd>lua toggle_nvim_tree()<CR>', default_settings)
map_key(n, '<Leader>f', '<Cmd>lua toggle_nvim_tree()<CR>', default_settings)

-- Grep for a string in the current directory.
map_key(exclude_t, '<F4>', '<Cmd>Telescope live_grep<CR>', default_settings)

-- Search for old files.
map_key(exclude_t, '<C-t>', '<Cmd>Telescope oldfiles<CR>', default_settings)

-- Cheatsheet.
map_key(all_modes, '<F12>', '<Cmd>Cheatsheet<CR>', default_settings)

-- Lazygit.
map_key(n, '<Leader>g', '<Cmd>LazyGit<CR>', default_settings)

-- Change lazygit repo.
map_key(all_modes, '<C-r>', '<Cmd>lua require("telescope").extensions.lazygit.lazygit()<CR>', default_settings)

-- Sessions.
map_key(n, '<F5>', '<Cmd>SSave<CR> " Saved current session.", "success", { title = " Session"} )<CR>', default_settings)

-- Moving windows.
map_key(n_t, '<C-h>','<Cmd>wincmd h<CR>', default_settings)
map_key(n_t, '<C-j>','<Cmd>wincmd j<CR>', default_settings)
map_key(n_t, '<C-k>','<Cmd>wincmd k<CR>', default_settings)
map_key(n_t, '<C-l>','<Cmd>wincmd l<CR>', default_settings)

-- Resizing windows.
map_key(n_t, '<C-=>','<Cmd>vertical resize +5<CR>', default_settings)
map_key(n_t, '<C-->','<Cmd>vertical resize -5<CR>', default_settings)
map_key(n_t, '<C-+>','<Cmd>horizontal resize +5<CR>', default_settings)
map_key(n_t, '<C-_>','<Cmd>horizontal resize -5<CR>', default_settings)

-- Commenting.
map_key(exclude_t, '<C-/>', '<Cmd>Commentary<CR>', default_settings)

-- Functions that only saves buffers that has files.
function Save_file()
    -- local readonly = vim.api.nvim_buf_get_option(0, 'readonly')
    local modifiable = vim.api.nvim_buf_get_option(0, 'modifiable')
    -- local nofile = vim.api.nvim_buf_get_option(0, 'buftype') == 'nofile'
    if modifiable then
        vim.cmd 'w!'
    end
end
map_key(exclude_t, '<C-s>', '<Cmd>lua Save_file()<CR>', default_settings)

-- Buffers.
map_key(exclude_t, '<C-Tab>', '<Cmd>Telescope buffers<CR>', default_settings)

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

------------
-- Barbar --
------------

-- Move.
map_key(n, '<C-<>', '<Cmd>BufferMovePrevious<CR>',  default_settings)
map_key(n, '<C->>', '<Cmd>BufferMoveNext<CR>',  default_settings)

-- Closing.
Close_current_buffer = require 'alex.ui.utils'.close_current_buffer_LV
map_key(n, '<C-q>', '<Cmd>BufferDelete<CR>', default_settings)
map_key(n, 'db',    '<Cmd>BufferPickDelete<CR>', default_settings)

-- Selecting.
map_key(n, 'gb',    '<Cmd>BufferPick<CR>', default_settings)
map_key(n, '<C-,>', '<Cmd>BufferPrevious<CR>', default_settings)
map_key(n, '<C-.>', '<Cmd>BufferNext<CR>', default_settings)

-- Pin buffer.
map_key(n, '<C-p>', '<Cmd>BufferPin<CR>', default_settings)

--------------
-- LSP Saga --
--------------

-- Go to reference (also shows definition).
map_key(n, "gr", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })

-- Code action
map_key(n_v, "ca", "<cmd>Lspsaga code_action<CR>", { silent = true })

-- Rename
map_key(n_v, "RR", "<cmd>Lspsaga rename<CR>", { silent = true })

-- Peek Definition
-- you can edit the definition file in this flaotwindow
-- also support open/vsplit/etc operation check definition_action_keys
-- support tagstack C-t jump back
map_key(n, "gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true })
map_key(n, "gf", "<cmd>Lspsaga goto_definition<CR>", { silent = true })

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
map_key(n, "<leader>o", "<cmd>Lspsaga outline<CR>",{ silent = true })

--------------
-- Terminal --
--------------

local terminal  = require('toggleterm.terminal').Terminal

-- Btop++.

-- local btop = Terminal:new({ cmd = "btop --utf-force", hidden = true, direction = "float" })
local btop = terminal:new({ cmd = "btop", hidden = true, direction = "float" })
-- local btop = Terminal:new({ cmd = "btm", hidden = true, direction = "float" })
function _btop_toggle()
  btop:toggle()
end
map_key(n, "<Leader>b", "<Cmd>lua _btop_toggle()<CR>", {noremap = true, silent = true})

-- Fish.

local fish = terminal:new({ cmd = "fish", hidden = true, direction = "float" })
function _fish_toggle()
  fish:toggle()
end
map_key(all_modes, "<F1>", "<Cmd>lua _fish_toggle()<CR>", default_settings)
map_key(n, "<Leader>t", "<Cmd>lua _fish_toggle()<CR>", default_settings)

------------
-- Vimtex --
------------

map_key(n, "gl", "<Cmd>VimtexView<CR>", default_settings)

-------------
-- Trouble --
-------------

map_key(n, "<leader>d", "<Cmd>TroubleToggle document_diagnostics<CR>", default_settings)
map_key(n, "<leader>D", "<Cmd>TroubleToggle workspace_diagnostics<CR>", default_settings)

-----------------------
-- Working directory --
-----------------------

-- Change the cwd to the directory of the current active buffer.
function _cwd_current_buffer()
    local abs_path = vim.api.nvim_buf_get_name(0)
    local dir = abs_path:match("(.*[/\\])")
    if dir == nil then
        return
    end
    vim.cmd ("cd " .. dir)
end

map_key(n_v, "gc", "<Cmd>lua _cwd_current_buffer()<CR><Cmd>NvimTreeRefresh<CR>", default_settings)

-----------------------
-- Debugger Protocol --
-----------------------

map_key(all_modes, "<A-d>", "<Cmd>DapContinue<CR>", default_settings)
map_key(all_modes, "<A-b>", "<Cmd>DapToggleBreakpoint<CR>", default_settings)

-- Stepping.
map_key(all_modes, "<A-o>", "<Cmd>DapStepOver<CR>", default_settings)
map_key(all_modes, "<A-T>", "<Cmd>DapTerminate<CR>", default_settings)
map_key(all_modes, "<A-i>", "<Cmd>DapStepInto<CR>", default_settings)
map_key(all_modes, "<A-u>", "<Cmd>DapStepOut<CR>", default_settings)
map_key(all_modes, "<A-c>", "<Cmd>DapContinue<CR>", default_settings)
map_key(all_modes, "<A-r>", "<Cmd>DapRestartFrame<CR>", default_settings)
map_key(all_modes, "<A-l>", "<Cmd>lua require 'dapui'.float_element('scopes')<CR>", default_settings)
map_key(all_modes, "<A-W>", "<Cmd>lua require 'dapui'.toggle()<CR>", default_settings)
