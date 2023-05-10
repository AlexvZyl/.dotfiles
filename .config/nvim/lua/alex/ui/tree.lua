-- Nvim-Tree.lua advises to do this at the start.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function root_label(path)
    path = path:gsub('/home/alex', ' ') .. '/'
    local path_len = path:len()
    local win_nr = require('nvim-tree.view').get_winnr()
    print(win_nr)
    local win_width = vim.fn.winwidth(win_nr)
    if path_len > (win_width - 2) then
        local max_str = path:sub(path_len - win_width + 5)
        local pos = max_str:find '/'
        if pos then
            return '󰉒 ' .. max_str:sub(pos)
        else
            return '󰉒 ' .. max_str
        end
    end
    return path
end

local icons = {
    git_placement = 'after',
    modified_placement = 'after',
    padding = ' ',
    glyphs = {
        default = '󰈔',
        folder = {
            arrow_closed = '',
            arrow_open = '',
            default = ' ',
            open = ' ',
            empty = ' ',
            empty_open = ' ',
            symlink = '󰉒 ',
            symlink_open = '󰉒 ',
        },
        git = {
            deleted = '',
            unstaged = '',
            untracked = '',
            staged = '',
            unmerged = '',
        },
    },
}

local renderer = {
    root_folder_label = root_label,
    indent_width = 2,
    indent_markers = {
        enable = true,
        inline_arrows = true,
        icons = { corner = '╰' }
    },
    icons = icons
}

local system_open = { cmd = 'zathura' }

local view = {
    cursorline = false,
    hide_root_folder = false,
    signcolumn = 'no',
    mappings = {
        list = {
            -- Allow moving out of the explorer.
            { key = '<C-i>', action = 'toggle_file_info' },
            { key = '<C-k>', action = '' },
            { key = '[', action = 'dir_up' },
            { key = ']', action = 'cd' },
            { key = '<Tab>', action = 'edit' },
            { key = 'o', action = 'system_open' },
        },
    },
    width = { max = 41, min = 40, padding = 1 },
}

-- Setup.
require('nvim-tree').setup {
    hijack_cursor = true,
    sync_root_with_cwd = true,
    view = view,
    system_open = system_open,
    renderer = renderer,
    git = {
        ignore = false,
    },
    diagnostics = {
        enable = true,
    },
}

-- Set window local options.
local api = require 'nvim-tree.api'
local Event = api.events.Event
api.events.subscribe(Event.TreeOpen, function(_)
    vim.cmd [[setlocal statuscolumn=\ ]]
    vim.cmd [[setlocal cursorlineopt=number]]
end)

-- Refresh on enter.
vim.api.nvim_create_autocmd({ 'WinEnter' }, {
    pattern = '*',
    command = 'NvimTreeRefresh',
})

-- When neovim opens.
local function open_nvim_tree(data)
    vim.cmd.cd(data.file:match '(.+)/[^/]*$')
    local directory = vim.fn.isdirectory(data.file) == 1
    if not directory then return end
    require('nvim-tree.api').tree.open()
end
vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = open_nvim_tree })
