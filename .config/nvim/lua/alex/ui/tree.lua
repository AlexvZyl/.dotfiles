-- Nvim-Tree.lua advises to do this at the start.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function root_label(path)
    path = path:gsub('/home/alex', ' ') .. '/'
    local path_len = path:len()
    local win_nr = require('nvim-tree.view').get_winnr()
    print(win_nr)
    local win_width = vim.fn.winwidth(win_nr)
    if path_len > (win_width-2) then
        local max_str = path:sub(path_len-win_width+5)
        local pos = max_str:find('/')
        if pos then
            return '󰉒 ' .. max_str:sub(pos)
        else
            return '󰉒 ' .. max_str
        end
    end
    return path
end

local renderer = {
    root_folder_label = root_label,
    indent_width = 2,
    indent_markers = {
        enable = true,
        inline_arrows = true,
        icons = {
            corner = '╰'
        }
    },
    icons = {
        git_placement = 'after',
        modified_placement = 'after',
        padding = ' ',
        glyphs = {
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
            }
        }
    }
}

local view = {
    cursorline = false,
    hide_root_folder = false,
    signcolumn = 'no',
    mappings = {
        list = {
            -- Allow moving out of the explorer.
            { key = "<C-i>", action = "toggle_file_info" },
            { key = "<C-k>", action = "" },
            { key = "[", action = "dir_up" },
            { key = "]", action = "cd" },
            { key = "<Tab>", action = "edit" }
        }
    },
    width = {
        max = 40,
        min = 40,
        padding = 1
    },
}

-- Setup.
require 'nvim-tree'.setup {
    hijack_cursor = true,
    sync_root_with_cwd = true,
    view = view,
    git = {
        ignore = false
    },
    renderer = renderer,
    diagnostics = {
        enable = true
    }
}
