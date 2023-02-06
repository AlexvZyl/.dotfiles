-- Nvim-Tree.lua advises to do this at the start.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local renderer = {
    root_folder_label = ":~:s?$?/..?",
    indent_width = 2,
    indent_markers = {
        enable = true,
        inline_arrows = true
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
            { key = "]", action = "cd" }
        }
    },
    width = {
        max = 40,
        min = 35,
        padding = 1
    },
}

local on_start = {

}

-- Setup.
require 'nvim-tree'.setup {
    hijack_cursor = true,
    sync_root_with_cwd = true,
    view = view,
    on_start = on_start,
    git = {
        ignore = false
    },
    renderer = renderer,
    diagnostics = {
        enable = true
    }
}
