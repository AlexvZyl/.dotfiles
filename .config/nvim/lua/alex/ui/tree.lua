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
            git= {
                deleted = '',
                unstaged = '',
                untracked = '',
                staged = '',
                unmerged = '',
            }
        }
    }
}

-- Setup.
require 'nvim-tree'.setup {
    hijack_cursor = true,
    sync_root_with_cwd = true,
    auto_reload_on_write = false,
    reload_on_bufenter = false,
    view = {
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
        width = 40
    },
    git = {
        ignore = false
    },
    renderer = renderer,
    diagnostics = {
        enable = true
    }
}
