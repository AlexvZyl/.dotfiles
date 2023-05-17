-- I want to keep all of the key bindings in one file so that it is easy to see
-- what is being used and ensure nothing being overwritten by accident.

-- Modes.
local ex_t = { 'n', 'i', 'v' }
local n_v = { 'n', 'v' }
local n = 'n'
local i = 'i'

-- API.
local map_key = vim.keymap.set
local default_settings = { noremap = true, silent = true }

-- Files & searching.
function Cwd_current_buffer()
    local abs_path = vim.api.nvim_buf_get_name(0)
    local dir = abs_path:match '(.*[/\\])'
    if dir == nil then return end
    vim.cmd('cd ' .. dir)
end
local cd = '<Cmd>lua Cwd_current_buffer()<CR><Cmd>NvimTreeRefresh<CR><Cmd>NvimTreeFindFile<CR>'
map_key(n_v, 'gc', cd, default_settings)
map_key(n_v, '<Leader>f', [[<Cmd>lua require('nvim-tree.api').tree.toggle {}<CR>]], default_settings)
map_key(n_v, '<C-t>', '<Cmd>Telescope oldfiles<CR>', default_settings)
map_key(n_v, 'ff', '<Cmd>Telescope find_files<CR>', default_settings)
map_key(n_v, 'fF', '<Cmd>Telescope find_files cwd=~<CR>', default_settings)
map_key(n_v, 'fs', '<Cmd>Telescope live_grep<CR>', default_settings)
map_key(n_v, 'fS', '<Cmd>Telescope live_grep cwd=~<CR>', default_settings)
map_key(n_v, '<C-f>', '<Cmd>Telescope current_buffer_fuzzy_find previewer=false<CR>', default_settings)

-- Windows.
map_key(ex_t, '<C-w><C-c>', '<Cmd>wincmd c<CR>', default_settings)
map_key(ex_t, '<C-h>', '<Cmd>wincmd h<CR>', default_settings)
map_key(ex_t, '<C-j>', '<Cmd>wincmd j<CR>', default_settings)
map_key(ex_t, '<C-k>', '<Cmd>wincmd k<CR>', default_settings)
map_key(ex_t, '<C-l>', '<Cmd>wincmd l<CR>', default_settings)
map_key(ex_t, '<C-Up>', ':resize -2<CR>', default_settings)
map_key(ex_t, '<C-Down>', ':resize +2<CR>', default_settings)
map_key(ex_t, '<C-Left>', ':vertical resize -2<CR>', default_settings)
map_key(ex_t, '<C-Right>', ':vertical resize +2<CR>', default_settings)

-- Editing.
map_key(ex_t, '<C-/>', '<Cmd>Commentary<CR>', default_settings)
map_key(ex_t, '<C-z>', '<Cmd>undo<CR>', default_settings)
map_key(ex_t, '<C-y>', '<Cmd>redo<CR>', default_settings)
map_key(i, '<Esc>', '<Esc>`^', default_settings)

-- Prevent trying to save invalid files.
function Save_file()
    if vim.api.nvim_buf_get_option(0, 'readonly') then return end
    local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
    if buftype == 'nofile' or buftype == 'prompt' then return end
    if vim.api.nvim_buf_get_option(0, 'modifiable') then vim.cmd 'w!' end
end
map_key(ex_t, '<C-s>', '<Cmd>lua Save_file()<CR>', default_settings)

-- Buffers.
-- C-Tab does not work...
map_key(ex_t, '<C-Tab>', '<Cmd>Telescope buffers<CR>', default_settings)
map_key(n, '<leader><leader>', '<Cmd>Telescope buffers<CR>', default_settings)

-- Barbar
map_key(n, '<C-q>', '<Cmd>BufferDelete<CR>', default_settings)
map_key(n, 'Q', '<Cmd>BufferDelete<CR>', default_settings)
map_key(n, 'db', '<Cmd>BufferPickDelete<CR>', default_settings)
map_key(n, 'gb', '<Cmd>BufferPick<CR>', default_settings)
map_key(n, 'H', '<Cmd>BufferPrevious<CR>', default_settings)
map_key(n, 'L', '<Cmd>BufferNext<CR>', default_settings)
-- map_key(n, '<C-H>', '<Cmd>BufferMovePrevious<CR>', default_settings)
-- map_key(n, '<C-L>', '<Cmd>BufferMoveNext<CR>', default_settings)
map_key(n, '<C-p>', '<Cmd>BufferPin<CR>', default_settings)

-- LSP.
map_key(n, '<leader>d', '<Cmd>TroubleToggle document_diagnostics<CR>', default_settings)
map_key(n, '<leader>D', '<Cmd>TroubleToggle workspace_diagnostics<CR>', default_settings)
map_key(n, 'gr', '<cmd>Lspsaga lsp_finder<CR>', { silent = true })
map_key(n_v, 'ca', '<cmd>Lspsaga code_action<CR>', { silent = true })
map_key(n_v, 'RR', '<cmd>Lspsaga rename<CR>', { silent = true })
map_key(n, 'gd', '<cmd>Lspsaga peek_definition<CR>', { silent = true })
map_key(n, 'gf', '<cmd>Lspsaga goto_definition<CR>zz', { silent = true })
map_key(n, 'gD', '<cmd>Lspsaga hover_doc<CR>', { silent = true })
map_key(n, 'e', '<cmd>Lspsaga show_line_diagnostics ++unfocus<CR>', { silent = true })
map_key(n, '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>', { silent = true })
map_key(n, ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>', { silent = true })
map_key(n, '<leader>o', '<cmd>Lspsaga outline<CR>', { silent = true })
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

-- Misc.
map_key(n, 'gl', '<Cmd>VimtexView<CR>', default_settings)
map_key(n_v, '<Esc>', '<Cmd>noh<CR>', { silent = true, noremap = false })
map_key(ex_t, '<F12>', '<Cmd>Cheatsheet<CR>', default_settings)

-- Debugger Protocol
-- TODO: Change chese keys!
map_key(ex_t, '<A-d>', '<Cmd>DapContinue<CR>', default_settings)
map_key(ex_t, '<A-b>', '<Cmd>DapToggleBreakpoint<CR>', default_settings)
map_key(ex_t, '<A-o>', '<Cmd>DapStepOver<CR>', default_settings)
map_key(ex_t, '<A-T>', '<Cmd>DapTerminate<CR>', default_settings)
map_key(ex_t, '<A-i>', '<Cmd>DapStepInto<CR>', default_settings)
map_key(ex_t, '<A-u>', '<Cmd>DapStepOut<CR>', default_settings)
map_key(ex_t, '<A-c>', '<Cmd>DapContinue<CR>', default_settings)
map_key(ex_t, '<A-r>', '<Cmd>DapRestartFrame<CR>', default_settings)
map_key(ex_t, '<A-l>', "<Cmd>lua require 'dapui'.float_element('scopes')<CR>", default_settings)
map_key(ex_t, '<A-W>', "<Cmd>lua require 'dapui'.toggle()<CR>", default_settings)

-- Completion.
local cmp = require 'cmp'
local luasnip = require 'luasnip'
cmp.setup {
    mapping = cmp.mapping.preset.insert {
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
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
