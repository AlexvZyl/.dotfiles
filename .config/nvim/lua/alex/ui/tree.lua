-- Nvim-Tree.lua advises to do this at the start.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Setup.
require 'nvim-tree'.setup {
    hijack_cursor = true,
    sync_root_with_cwd = true,
    auto_reload_on_write = true,
    reload_on_bufenter = false,
    respect_buf_cwd = true,
    update_focused_file = {
        -- enable = true,
        enable = false,
        update_cwd = true,
        debounce_delay = 1000,
        ignore_list = {},
    },
    view = {
        hide_root_folder = false,
        signcolumn = 'no',
        mappings = {
            list = {
                -- Allow moving out of the explorer.
                { key = "<C-i>", action = "toggle_file_info" },
                { key = "<C-k>", action = "" }
            }
        },
        width = 40
    },
    git = {
        ignore = false
    },
    renderer = {
        indent_markers = {
            enable = true
        }
    },
    diagnostics = {
        enable = true
    }
}
