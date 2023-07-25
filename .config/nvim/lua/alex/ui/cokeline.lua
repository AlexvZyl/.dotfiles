local P = require 'nordic.colors'

local blend = require('nordic.utils').blend
local inactive_bg = blend(P.bg, P.black, 0.4)

require('cokeline').setup {
    default_hl = {
        fg = function(buffer) return buffer.is_focused and P.fg or P.gray4 end,
        bg = function(buffer) return buffer.is_focused and P.bg or inactive_bg end,
        --style = function(buffer) return not buffer.is_focused and 'underline' end,
        --sp = P.black0,
    },
    sidebar = {
        filetype = 'NvimTree',
        components = {
            {
                text = ' 󰙅  File Explorer',
                fg = P.yellow.base,
                bg = P.black0,
                style = 'bold',
            },
        },
    },

    components = {
        {
            text = function(buffer)
                if buffer.index == 1 and require('nvim-tree.api').tree.is_visible() then return ' ' end
                return ''
            end,
            bg = P.black0,
        },
        {
            text = function(buffer) return (buffer.index ~= 1) and '▎  ' or '   ' end,
            fg = P.black0,
        },
        {
            text = function(buffer)
                if buffer.diagnostics.errors ~= 0 then return ' ' end
                if buffer.diagnostics.warnings ~= 0 then return ' ' end
                return buffer.devicon.icon
            end,
            fg = function(buffer)
                if buffer.diagnostics.errors ~= 0 then return P.error end
                if buffer.diagnostics.warnings ~= 0 then return P.warn end
                return buffer.is_focused and buffer.devicon.color
            end,
        },
        {
            text = ' ',
        },
        {
            text = function(buffer) return buffer.filename .. '  ' end,
        },
        {
            text = function(buffer)
                if buffer.is_readonly then return '' end
                if buffer.is_modified then return '●' end
                return ''
            end,
            delete_buffer_on_left_click = true,
        },
        {
            text = '   ',
        },
    },
}
