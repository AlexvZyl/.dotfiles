local M = {}

function M.cwd_current_buffer()
    local abs_path = vim.api.nvim_buf_get_name(0)
    local dir = abs_path:match '(.*[/\\])'
    if dir == nil then return end
    vim.cmd('cd ' .. dir)
    vim.cmd 'NvimTreeRefresh'
    vim.cmd 'NvimTreeFindFile'
end

function M.toggle_tree()
    local tree = require('nvim-tree.api').tree
    if not tree.is_visible() then
    end
    tree.toggle {}
end

function M.save_file()
    if vim.api.nvim_buf_get_option(0, 'readonly') then return end
    local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
    if buftype == 'nofile' or buftype == 'prompt' then return end
    if vim.api.nvim_buf_get_option(0, 'modifiable') then vim.cmd 'w!' end
end

function M.next_error() require('lspsaga.diagnostic').goto_prev { severity = vim.diagnostic.severity.ERROR } end

function M.prev_error() require('lspsaga.diagnostic').goto_next { severity = vim.diagnostic.severity.ERROR } end

return M
