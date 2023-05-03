-- I want to keep all of the key bindings in one file so that it is easy to see
-- what is being used and ensure nothing being overwritten by accident.

local u = require 'alex.utils'

--------------------------
-- General key bindings --
--------------------------

-- Modes.
local all = { 'n', 'i', 'v', 't' }
local ex_t = { 'n', 'i', 'v' }
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

-- Sometimes I do not lift the ctrl key when trying to close a window.
-- Why does this not work?
map_key(n, '<C-w><C-c>', '<Cmd>wincmd c<CR>', default_settings)

-- Search for files in current directory.
map_key(ex_t, '<F3>', '<Cmd>Telescope find_files<CR>', default_settings)

-- Toggle the file explorer.
function Toggle_nvim_tree()
    require('nvim-tree.api').tree.toggle {}
    local is_open = require('nvim-tree.view').is_visible()
    if is_open then vim.wo.statuscolumn = ' ' end
end
map_key(ex_t, '<F2>', '<Cmd>lua Toggle_nvim_tree()<CR>', default_settings)
map_key(n, '<Leader>f', '<Cmd>lua Toggle_nvim_tree()<CR>', default_settings)

-- Grep for a string in the current directory.
map_key(ex_t, '<F4>', '<Cmd>Telescope live_grep<CR>', default_settings)

-- Search for old files.
map_key(ex_t, '<C-t>', '<Cmd>Telescope oldfiles<CR>', default_settings)

-- Cheatsheet.
map_key(ex_t, '<F12>', '<Cmd>Cheatsheet<CR>', default_settings)

-- Moving windows.
map_key(n, '<C-h>', '<Cmd>wincmd h<CR>', default_settings)
map_key(n, '<C-j>', '<Cmd>wincmd j<CR>', default_settings)
map_key(n, '<C-k>', '<Cmd>wincmd k<CR>', default_settings)
map_key(n, '<C-l>', '<Cmd>wincmd l<CR>', default_settings)

-- Resizing windows.
map_key(n, '<C-Up>', ':resize -2<CR>', default_settings)
map_key(n, '<C-Down>', ':resize +2<CR>', default_settings)
map_key(n, '<C-Left>', ':vertical resize -2<CR>', default_settings)
map_key(n, '<C-Right>', ':vertical resize +2<CR>', default_settings)

-- Commenting.
map_key(ex_t, '<C-/>', '<Cmd>Commentary<CR>', default_settings)

-- Functions that only saves buffers that has files.
function Save_file()
    -- local readonly = vim.api.nvim_buf_get_option(0, 'readonly')
    local modifiable = vim.api.nvim_buf_get_option(0, 'modifiable')
    -- local nofile = vim.api.nvim_buf_get_option(0, 'buftype') == 'nofile'
    if modifiable then vim.cmd 'w!' end
end
map_key(ex_t, '<C-s>', '<Cmd>lua Save_file()<CR>', default_settings)

-- Buffers.
map_key(ex_t, '<C-Tab>', '<Cmd>Telescope buffers<CR>', default_settings)

-- Finding.
map_key(ex_t, '<C-f>', '<Cmd>Telescope current_buffer_fuzzy_find previewer=false<CR>', default_settings)

-- Undo.
map_key(ex_t, '<C-Z>', '<Cmd>undo<CR>', default_settings)

-- Redo.
map_key(ex_t, '<C-Y>', '<Cmd>redo<CR>', default_settings)

-- Zen mode.
map_key(all, '<C-a>', '<Cmd>TZAtaraxis<CR>', default_settings)

----------
-- Tmux --
----------

map_key(n, 'p', ':!tmux send-keys ', default_settings)

------------
-- Barbar --
------------

-- Move.
map_key(n, '<C-<>', '<Cmd>BufferMovePrevious<CR>', default_settings)
map_key(n, '<C->>', '<Cmd>BufferMoveNext<CR>', default_settings)

-- Closing.
map_key(n, '<C-q>', '<Cmd>BufferDelete<CR>', default_settings)
map_key(n, 'db', '<Cmd>BufferPickDelete<CR>', default_settings)

-- Selecting.
map_key(n, 'gb', '<Cmd>BufferPick<CR>', default_settings)
map_key(n, '<C-,>', '<Cmd>BufferPrevious<CR>', default_settings)
map_key(n, '<C-.>', '<Cmd>BufferNext<CR>', default_settings)

-- Pin buffer.
map_key(n, '<C-p>', '<Cmd>BufferPin<CR>', default_settings)

--------------
-- LSP Saga --
--------------

-- Go to reference (also shows definition).
map_key(n, 'gr', '<cmd>Lspsaga lsp_finder<CR>', { silent = true })

-- Code action
map_key(n_v, 'ca', '<cmd>Lspsaga code_action<CR>', { silent = true })

-- Rename
map_key(n_v, 'RR', '<cmd>Lspsaga rename<CR>', { silent = true })

-- Peek Definition
-- you can edit the definition file in this flaotwindow
-- also support open/vsplit/etc operation check definition_action_keys
-- support tagstack C-t jump back
map_key(n, 'gd', '<cmd>Lspsaga peek_definition<CR>', { silent = true })
map_key(n, 'gf', '<cmd>Lspsaga goto_definition<CR>', { silent = true })

-- Show docs.
map_key(n, 'gD', '<cmd>Lspsaga hover_doc<CR>', { silent = true })

-- Show line diagnostics
map_key(n, 'L', '<cmd>Lspsaga show_line_diagnostics ++unfocus<CR>', { silent = true })

-- Diagnsotic jump can use `<c-o>` to jump back
map_key(n, '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>', { silent = true })
map_key(n, ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>', { silent = true })

-- Only jump to error
map_key(
    n,
    '[E',
    function() require('lspsaga.diagnostic').goto_prev { severity = vim.diagnostic.severity.ERROR } end,
    { silent = true }
)
map_key(
    n,
    ']E',
    function() require('lspsaga.diagnostic').goto_next { severity = vim.diagnostic.severity.ERROR } end,
    { silent = true }
)

-- Outline
map_key(n, '<leader>o', '<cmd>Lspsaga outline<CR>', { silent = true })

--------------
-- Terminal --
--------------

-- Remain in terminal mode.
-- map_key(t, '<Esc>', '<Nop>', default_settings)

function New_tmux_shell_current_dir()
    local abs_path = vim.api.nvim_buf_get_name(0)
    local dir = abs_path:match '(.*[/\\])'
    if dir == nil then return end
    vim.fn.system('tmux new-window -c ' .. dir)
end

-- Open new tmux windows.
map_key(n, '<Leader>t', '<Cmd>lua New_tmux_shell_current_dir()<CR>', default_settings)
map_key(n, '<Leader>s', '<Cmd>lua New_tmux_shell_current_dir()<CR>', default_settings)
map_key(n, '<F1>', '<Cmd>lua New_tmux_shell_current_dir()<CR>', default_settings)
map_key(n, '<Leader>b', ':!tmux new-window -n "btop" btop<CR>', default_settings)
map_key(n, '<Leader>g', ':!tmux new-window -n "lazygit" lazygit<CR>', default_settings)

--[[
local terminal = require('toggleterm.terminal').Terminal

-- Btop++.
local btop = terminal:new { cmd = 'btop', hidden = true, direction = 'float' }
function Btop_toggle() btop:toggle() end
map_key(n, '<Leader>b', '<Cmd>lua Btop_toggle()<CR>', default_settings)

-- Tmux & fish.
local tmux =
    terminal:new { cmd = 'tmux', hidden = true, direction = 'float', float_opts = { border = u.border_chars_tmux } }
function Tmux_toggle() tmux:toggle() end
map_key(all, '<F1>', '<Cmd>lua Tmux_toggle()<CR>', default_settings)
map_key(n, '<Leader>t', '<Cmd>lua Fish_toggle()<CR>', default_settings)

-- Lazygit.
local lazygit = terminal:new { cmd = 'lazygit', hidden = true, direction = 'float' }
function Lazygit_toggle() lazygit:toggle() end
map_key(n, '<Leader>g', '<Cmd>lua Lazygit_toggle()<CR>', default_settings)
--]]

------------
-- Vimtex --
------------

map_key(n, 'gl', '<Cmd>VimtexView<CR>', default_settings)

-------------
-- Trouble --
-------------

map_key(n, '<leader>d', '<Cmd>TroubleToggle document_diagnostics<CR>', default_settings)
map_key(n, '<leader>D', '<Cmd>TroubleToggle workspace_diagnostics<CR>', default_settings)

-----------------------
-- Working directory --
-----------------------

-- Change the cwd to the directory of the current active buffer.
function Cwd_current_buffer()
    local abs_path = vim.api.nvim_buf_get_name(0)
    local dir = abs_path:match '(.*[/\\])'
    if dir == nil then return end
    vim.cmd('cd ' .. dir)
end

map_key(
    n_v,
    'gc',
    '<Cmd>lua Cwd_current_buffer()<CR><Cmd>NvimTreeRefresh<CR><Cmd>NvimTreeFindFile<CR>',
    default_settings
)

-----------------------
-- Debugger Protocol --
-----------------------

map_key(ex_t, '<A-d>', '<Cmd>DapContinue<CR>', default_settings)
map_key(ex_t, '<A-b>', '<Cmd>DapToggleBreakpoint<CR>', default_settings)

-- Stepping.
map_key(ex_t, '<A-o>', '<Cmd>DapStepOver<CR>', default_settings)
map_key(ex_t, '<A-T>', '<Cmd>DapTerminate<CR>', default_settings)
map_key(ex_t, '<A-i>', '<Cmd>DapStepInto<CR>', default_settings)
map_key(ex_t, '<A-u>', '<Cmd>DapStepOut<CR>', default_settings)
map_key(ex_t, '<A-c>', '<Cmd>DapContinue<CR>', default_settings)
map_key(ex_t, '<A-r>', '<Cmd>DapRestartFrame<CR>', default_settings)
map_key(ex_t, '<A-l>', "<Cmd>lua require 'dapui'.float_element('scopes')<CR>", default_settings)
map_key(ex_t, '<A-W>', "<Cmd>lua require 'dapui'.toggle()<CR>", default_settings)

--------
-- AI --
--------

if vim.env.OPENAI_API_KEY then map_key(n, '<Leader>c', '<Cmd>ChatGPT<CR>', default_settings) end
