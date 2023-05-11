local u = require 'alex.utils'

-- Offset for tree.
local nvim_tree_events = require 'nvim-tree.events'
local bufferline_api = require 'bufferline.api'
local function get_tree_size() return require('nvim-tree.view').View.width end
nvim_tree_events.subscribe('TreeOpen', function() bufferline_api.set_offset(get_tree_size()) end)
nvim_tree_events.subscribe('Resize', function() bufferline_api.set_offset(get_tree_size()) end)
nvim_tree_events.subscribe('TreeClose', function() bufferline_api.set_offset(0) end)

-- Icons.
local def_sep = { left = ' ', right = ' ' }
local def_buf = { separator = def_sep }
local icons = {
    separator = { left = '', right = '' },
    button = '',
    inactive = def_buf,
    visible = def_buf,
    alternate = def_buf,
    current = { separator = { left = u.left_thick, right = ' ' } },
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

-- Setup
require('bufferline').setup {
    tabpages = false,
    icons = icons,
    animation = true,
    auto_hide = true,
    highlight_inactive_file_icons = false,
    minimum_padding = 1,
    maximum_length = 20,
    exclude_ft = { 'dap-repl' },
}
