-- I want to keep all of the key bindings in one file so that it is easy to see
-- what is being used and ensure nothing being overwritten by accident.

local n, i, v = 'n', 'i', 'v'
local ex_t = { n, i, v }
local n_v = { n, v }

local keymap = vim.keymap.set
local default_settings = { noremap = true, silent = true }
local allow_remap = { noremap = false, silent = true }

-- Tree.
keymap(n_v, 'gc', function() require('alex.keymaps.utils').cwd_current_buffer() end, default_settings)
keymap(n_v, '<Leader>f', function() require('alex.keymaps.utils').toggle_tree() end, default_settings)

-- Telescope.
keymap(n_v, '<C-t>', '<Cmd>Telescope oldfiles<CR>', default_settings)
keymap(n_v, 'ff', '<Cmd>Telescope find_files<CR>', default_settings)
keymap(n_v, 'fF', '<Cmd>Telescope find_files cwd=~<CR>', default_settings)
keymap(n_v, 'fs', '<Cmd>Telescope live_grep<CR>', default_settings)
keymap(n_v, 'fS', '<Cmd>Telescope live_grep cwd=~<CR>', default_settings)
keymap(n_v, '<C-f>', '<Cmd>Telescope current_buffer_fuzzy_find previewer=false<CR>', default_settings)
keymap(ex_t, '<F12>', '<Cmd>Cheatsheet<CR>', default_settings)
keymap(n, '<leader>b', '<Cmd>Telescope buffers<CR>', default_settings)

-- Windows.
keymap(ex_t, '<C-w><C-c>', '<Cmd>wincmd c<CR>', default_settings)
keymap(ex_t, '<C-h>', '<Cmd>wincmd h<CR>', default_settings)
keymap(ex_t, '<C-j>', '<Cmd>wincmd j<CR>', default_settings)
keymap(ex_t, '<C-k>', '<Cmd>wincmd k<CR>', default_settings)
keymap(ex_t, '<C-l>', '<Cmd>wincmd l<CR>', default_settings)
keymap(ex_t, '<C-Up>', ':resize -2<CR>', default_settings)
keymap(ex_t, '<C-Down>', ':resize +2<CR>', default_settings)
keymap(ex_t, '<C-Left>', ':vertical resize -2<CR>', default_settings)
keymap(ex_t, '<C-Right>', ':vertical resize +2<CR>', default_settings)

-- Editing.
keymap(ex_t, '<C-/>', '<Cmd>Commentary<CR>', default_settings)
keymap(ex_t, '<C-z>', '<Cmd>undo<CR>', default_settings)
keymap(ex_t, '<C-y>', '<Cmd>redo<CR>', default_settings)
keymap(i, '<Esc>', '<Esc>`^', default_settings)
keymap(n, '/', '<Nop>', default_settings)
keymap(n, '?', '<Nop>', default_settings)
keymap(ex_t, '<C-s>', function() require('alex.keymaps.utils').save_file() end, default_settings)
keymap(v, '<Esc>', 'v', default_settings)

-- Barbar
keymap(n, '<C-q>', '<Cmd>BufferDelete<CR>', default_settings)
keymap(n, 'Q', '<Cmd>BufferDelete<CR>', default_settings)
keymap(n, 'db', '<Cmd>BufferPickDelete<CR>', default_settings)
keymap(n, 'gb', '<Cmd>BufferPick<CR>', default_settings)
keymap(n, 'H', '<Cmd>BufferPrevious<CR>', default_settings)
keymap(n, 'L', '<Cmd>BufferNext<CR>', default_settings)
keymap(n, '<C-p>', '<Cmd>BufferPin<CR>', default_settings)

-- LSP.
keymap(n, '<leader>d', '<Cmd>TroubleToggle document_diagnostics<CR>', default_settings)
keymap(n, '<leader>D', '<Cmd>TroubleToggle workspace_diagnostics<CR>', default_settings)
keymap(n, 'gr', '<cmd>Lspsaga lsp_finder<CR>', default_settings)
keymap(n_v, 'ca', '<cmd>Lspsaga code_action<CR>', default_settings)
keymap(n_v, 'RR', '<cmd>Lspsaga rename<CR>', default_settings)
keymap(n, 'gd', '<cmd>Lspsaga peek_definition<CR>', default_settings)
keymap(n, 'gf', '<cmd>Lspsaga goto_definition<CR>zz', default_settings)
keymap(n, 'gD', '<cmd>Lspsaga hover_doc<CR>', default_settings)
keymap(n, 'e', '<cmd>Lspsaga show_line_diagnostics ++unfocus<CR>', default_settings)
keymap(n, '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>', default_settings)
keymap(n, ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>', default_settings)
keymap(n, '<leader>o', '<cmd>Lspsaga outline<CR>', default_settings)
keymap(n, '[E', function() require('alex.keymaps.utils').next_error() end, default_settings)
keymap(n, ']E', function() require('alex.keymaps.utils').prev_error() end, default_settings)

-- Misc.
keymap(n, 'gl', '<Cmd>VimtexView<CR>', default_settings)
keymap(n, '<Esc>', '<Cmd>noh<CR>', allow_remap)

-- Debugger.
keymap(n, 'S', function() require('dapui').float_element 'scopes' end, default_settings)
keymap(n, '<C-b>', '<Cmd>DapToggleBreakpoint<CR>', default_settings)
keymap(n, '<F1>', function() require('dapui').toggle() end, default_settings)
keymap(n, '<F2>', '<Cmd>DapContinue<CR>', default_settings)
keymap(n, '<F3>', '<Cmd>DapStepInto<CR>', default_settings)
keymap(n, '<F4>', '<Cmd>DapStepOver<CR>', default_settings)
keymap(n, '<F5>', '<Cmd>DapStepOut<CR>', default_settings)
keymap(n, '<F6>', '<Cmd>DapRestartFrame<CR>', default_settings)
keymap(n, '<F7>', '<Cmd>DapTerminate<CR>', default_settings)

-- Completion.
local cmp = require 'cmp'
local luasnip = require 'luasnip'
cmp.setup {
    mapping = cmp.mapping.preset.insert {
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm { select = false },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
}
