-- I want to keep all of the key bindings in one file so that it is easy to see
-- what is being used and ensure nothing being overwritten by accident.

local n, i, v, t = 'n', 'i', 'v', 't'
local ex_t = { n, i, v }
local ex_i = { n, v, t }
local n_v = { n, v }

local keymap = vim.keymap.set
local default_settings = { noremap = true, silent = true }
local allow_remap = { noremap = false, silent = true }

local M = {}

function M.init()
    -- Telescope
    keymap(n_v, '<C-t>', '<Cmd>Telescope oldfiles<CR>', default_settings)
    keymap(n_v, 'ff', '<Cmd>Telescope find_files<CR>', default_settings)
    keymap(n_v, 'fF', '<Cmd>Telescope find_files cwd=~<CR>', default_settings)
    keymap(n_v, 'fs', '<Cmd>Telescope live_grep<CR>', default_settings)
    keymap(n_v, 'fS', '<Cmd>Telescope live_grep cwd=~<CR>', default_settings)
    keymap(n_v, '<C-f>', '<Cmd>Telescope current_buffer_fuzzy_find previewer=false<CR>', default_settings)
    keymap(ex_t, '<F12>', '<Cmd>Cheatsheet<CR>', default_settings)
    keymap(n, '<leader>b', '<Cmd>Telescope buffers<CR>', default_settings)

    -- Tree
    keymap(n_v, 'gc', function() require('alex.keymaps.utils').cwd_current_buffer() end, default_settings)
    keymap(n_v, '<Leader>f', function() require('alex.keymaps.utils').toggle_tree() end, default_settings)

    -- Cokeline
    keymap(n, 'Q', function() require('alex.keymaps.utils').delete_buffer() end, default_settings)
    keymap(n, 'H', '<Plug>(cokeline-focus-prev)', default_settings)
    keymap(n, 'L', '<Plug>(cokeline-focus-next)', default_settings)
    keymap(n, 'gb', '<Plug>(cokeline-focus-pick)', default_settings)

    -- Misc
    keymap(n, 'gl', '<Cmd>VimtexView<CR>', default_settings)
    keymap(n, '<Esc>', '<Cmd>noh<CR>', allow_remap)

    -- Trouble
    keymap(n, '<leader>d', '<Cmd>TroubleToggle document_diagnostics<CR>', default_settings)
    keymap(n, '<leader>D', '<Cmd>TroubleToggle workspace_diagnostics<CR>', default_settings)

    M.editing()
    M.windows()
end

function M.windows()
    keymap(ex_t, '<C-w><C-c>', '<Cmd>wincmd c<CR>', default_settings)
    keymap(ex_t, '<C-h>', '<Cmd>wincmd h<CR>', default_settings)
    keymap(ex_t, '<C-j>', '<Cmd>wincmd j<CR>', default_settings)
    keymap(ex_t, '<C-k>', '<Cmd>wincmd k<CR>', default_settings)
    keymap(ex_t, '<C-l>', '<Cmd>wincmd l<CR>', default_settings)
end

function M.editing()
    keymap(ex_t, '<C-z>', '<Cmd>undo<CR>', default_settings)
    keymap(ex_t, '<C-y>', '<Cmd>redo<CR>', default_settings)
    keymap(i, '<Esc>', '<Esc>`^', default_settings)
    keymap(ex_t, '<C-s>', function() require('alex.keymaps.utils').save_file() end, default_settings)
    keymap(v, '<Esc>', 'v', default_settings)
    keymap(v, 'i', 'I', default_settings)
    keymap(n_v, '<C-c>', '<plug>NERDCommenterToggle', default_settings)
    keymap(n, 's', function() require('leap').leap {} end)
    keymap(n, 'S', function() require('leap').leap { backward = true } end)
    keymap(n, '<leader>v', function() require('alex.keymaps.utils').toggle_diffview() end)
    keymap(n, '<C-a>', 'gg0vG$', default_settings)
    keymap(ex_i, 'dd', '"_dd', default_settings)
    keymap(ex_i, 'dw', '"_dw', default_settings)
    keymap(ex_i, 'd', '"_d', default_settings)
end

function M.vscode()
    M.editing()
    M.windows()
end

function M.lspsaga()
    keymap(n_v, 'ca', '<Cmd>Lspsaga code_action<CR>', default_settings)
    keymap(n_v, 'RR', '<Cmd>Lspsaga rename<CR>', default_settings)
    keymap(n, 'gd', '<Cmd>Lspsaga peek_definition<CR>', default_settings)
    keymap(n, 'gD', '<Cmd>Lspsaga hover_doc<CR>', default_settings)
    keymap(n, 'gf', '<Cmd>Lspsaga goto_definition<CR>zz', default_settings)
    keymap(n, 'e', '<Cmd>Lspsaga show_line_diagnostics ++unfocus<CR>', default_settings)
    keymap(n, '<leader>o', '<Cmd>Lspsaga outline<CR>', default_settings)
    keymap(n, '[e', function() require('alex.keymaps.utils').prev_diag() end, default_settings)
    keymap(n, ']e', function() require('alex.keymaps.utils').next_diag() end, default_settings)
    keymap(n, '[E', function() require('alex.keymaps.utils').prev_error() end, default_settings)
    keymap(n, ']E', function() require('alex.keymaps.utils').next_error() end, default_settings)
    keymap(n, 'gr', '<Cmd>Telescope lsp_references<CR>', default_settings)
end

function M.debugger()
    keymap(n, '<C-b>', '<Cmd>DapToggleBreakpoint<CR>', default_settings)
    keymap(n, '<leader>s', function() require('alex.keymaps.utils').dap_float_scope() end, default_settings)
    keymap(n, '<F1>', function() require('alex.keymaps.utils').dap_toggle_ui() end, default_settings)
    keymap(n, '<F2>', '<Cmd>DapContinue<CR>', default_settings)
    keymap(n, '<Right>', '<Cmd>DapStepInto<CR>', default_settings)
    keymap(n, '<Down>', '<Cmd>DapStepOver<CR>', default_settings)
    keymap(n, '<Left>', '<Cmd>DapStepOut<CR>', default_settings)
    keymap(n, '<Up>', '<Cmd>DapRestartFrame<CR>', default_settings)
end

function M.completion()
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
                elseif luasnip.expand_or_locally_jumpable() then
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
end

return M
