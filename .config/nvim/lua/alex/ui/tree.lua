-- Nvim-Tree.lua advises to do this at the start.
--vim.g.loaded_netrw = 1
--vim.g.loaded_netrwPlugin = 1

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
        icons = { corner = '╰' },
    },
    icons = icons,
}

local system_open = { cmd = 'zathura' }

local view = {
    cursorline = false,
    hide_root_folder = false,
    signcolumn = 'no',
    width = { max = 38, min = 38, padding = 1 },
}

local function on_attach(bufnr)
    local api = require 'nvim-tree.api'
    local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    vim.keymap.set('n', '<C-k>', '', { buffer = bufnr })
    vim.keymap.del('n', '<C-k>', { buffer = bufnr })
    vim.keymap.set('n', 'i', api.node.show_info_popup, opts 'Info')
    vim.keymap.set('n', '[', api.tree.change_root_to_parent, opts 'Up')
    vim.keymap.set('n', ']', api.tree.change_root_to_node, opts 'CD')
    vim.keymap.set('n', '<Tab>', api.node.open.edit, opts 'Open')
    vim.keymap.set('n', 'o', api.node.run.system, opts 'Run System')
    vim.keymap.set('n', 'a', api.fs.create, { buffer = bufnr })
    vim.keymap.set('n', 'd', api.fs.remove, { buffer = bufnr })
    vim.keymap.set('n', 'x', api.fs.cut, opts 'Cut')
    vim.keymap.set('n', 'y', api.fs.copy.filename, opts 'Copy Name')
    vim.keymap.set('n', 'p', api.fs.paste, opts 'Paste')
    vim.keymap.set('n', 'r', api.fs.rename, opts 'Rename')
    vim.keymap.set('n', 'W', api.tree.collapse_all, opts 'Collapse')
    vim.keymap.set('n', 'E', api.tree.expand_all, opts 'Expand All')
end

require('nvim-tree').setup {
    hijack_cursor = true,
    sync_root_with_cwd = true,
    view = view,
    system_open = system_open,
    renderer = renderer,
    git = { ignore = false },
    diagnostics = { enable = true },
    on_attach = on_attach,
}

-- Set window local options.
local api = require 'nvim-tree.api'
local Event = api.events.Event
api.events.subscribe(Event.TreeOpen, function(_)
    vim.cmd [[setlocal statuscolumn=\ ]]
    vim.cmd [[setlocal cursorlineopt=number]]
end)

-- When neovim opens.
local function open_nvim_tree(data)
    vim.cmd.cd(data.file:match '(.+)/[^/]*$')
    local directory = vim.fn.isdirectory(data.file) == 1
    if not directory then return end
    require('nvim-tree.api').tree.open()
end
vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = open_nvim_tree })
