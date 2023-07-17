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
    tree.toggle {}
end

function M.save_file()
    if vim.api.nvim_buf_get_option(0, 'readonly') then return end
    local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
    if buftype == 'nofile' or buftype == 'prompt' then return end
    if vim.api.nvim_buf_get_option(0, 'modifiable') then vim.cmd 'w!' end
end

function M.next_error()
    vim.diagnostic.goto_next {
        severity = vim.diagnostic.severity.ERROR,
        float = false,
    }
    vim.cmd [[Lspsaga show_line_diagnostics ++unfocus]]
end

function M.prev_error()
    vim.diagnostic.goto_prev {
        severity = vim.diagnostic.severity.ERROR,
        float = false,
    }
    vim.cmd [[Lspsaga show_line_diagnostics ++unfocus]]
end

function M.next_diag()
    vim.diagnostic.goto_next {
        float = false,
    }
    vim.cmd [[Lspsaga show_line_diagnostics ++unfocus]]
end

function M.prev_diag()
    vim.diagnostic.goto_prev {
        float = false,
    }
    vim.cmd [[Lspsaga show_line_diagnostics ++unfocus]]
end

M.DAP_UI_ENABLED = false
function M.dap_toggle_ui()
    require('dapui').toggle()
    M.DAP_UI_ENABLED = true
end

function M.dap_float_scope()
    if not M.DAP_UI_ENABLED then return end
    require('dapui').float_element 'scopes'
end

function M.toggle_diffview()
    local view = require('diffview.lib').get_current_view()
    if view then
        vim.cmd 'DiffviewClose'
    else
        vim.cmd 'DiffviewOpen'
    end
end

function M.delete_buffer()
    local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
    if buftype == 'nofile' or buftype == 'prompt' then return end
    if vim.api.nvim_buf_get_option(0, 'modified') then return end
    vim.cmd [[:bp | bdelete #]]
end

return M
