-- Nvim-Tree.lua advises to do this at the start.
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

-- Setup.
require 'nvim-tree'.setup {
    -- auto_reload_on_write = true,
    -- reload_on_bufenter = false,
    -- sync_root_with_cwd = true,
    -- update_cwd = true,
    -- respect_buf_cwd = true,
    -- update_focused_file = {
        -- enable = true,
        -- update_cwd = true,
        -- ignore_list = {},
    -- },
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
