local get_hex = require('cokeline/utils').get_hex

local yellow = vim.g.terminal_color_3

require('cokeline').setup {
    default_hl = {
        fg = function(buffer) return buffer.is_focused and get_hex('Normal', 'fg') or get_hex('Comment', 'fg') end,
        bg = 'NONE',
    },
    sidebar = {
        filetype = 'NvimTree',
        components = {
            {
                text = ' 󰙅  File Explorer',
                fg = yellow,
                bg = get_hex('NvimTreeNormal', 'bg'),
                style = 'bold',
            },
        },
    },

    components = {
        {
            text = function(buffer) return (buffer.index ~= 1) and '▏' or '' end,
        },
        {
            text = '  ',
        },
        {
            text = function(buffer) return buffer.devicon.icon end,
            fg = function(buffer) return buffer.devicon.color end,
        },
        {
            text = ' ',
        },
        {
            text = function(buffer) return buffer.filename .. '  ' end,
            style = function(buffer) return buffer.is_focused and 'bold' or nil end,
        },
        {
            text = '',
            delete_buffer_on_left_click = true,
        },
        {
            text = '  ',
        },
    },
}
