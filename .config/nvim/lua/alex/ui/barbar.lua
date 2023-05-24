local u = require 'alex.utils'

local default = { separator = { left = '', right = u.right_thick } }
local icons = {
    button = '',
    inactive = default,
    visible = default,
    alternate = default,
    current = default,
    diagnostics = {
        enabled = true,
        { enabled = true, icon = ' ' }, -- Error.
        { enabled = false, icon = ' ' }, -- Warning.
        { enabled = false }, -- Info.
        { enabled = false }, -- Hint.
    },
    gitsigns = { enabled = false },
    modified = { button = '●' },
    pinned = { button = '󰐃', filename = true },
}

local sidebar = {
    NvimTree = { text = "File Explorer" },
}

require('bufferline').setup {
    sidebar_filetypes = sidebar,
    tabpages = false,
    icons = icons,
    animation = true,
    auto_hide = false,
    highlight_inactive_file_icons = false,
    minimum_padding = 1,
    minimum_length = 9,
    maximum_length = 20,
    exclude_ft = { 'dap-repl' },
}
