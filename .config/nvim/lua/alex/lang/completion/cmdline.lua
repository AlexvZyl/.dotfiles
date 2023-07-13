local cmp = require 'cmp'
local u = require 'alex.utils'

-- UI
local cmdline_window = {
    completion = cmp.config.window.bordered {
        winhighlight = 'Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
        scrollbar = true,
        border = u.border_chars_outer_thin,
        col_offset = -4,
        side_padding = 0,
    },
}

-- Source
local cmdline = {
    window = cmdline_window,
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources {
        { name = 'path' },
        { name = 'cmdline' },
    },
}

cmp.setup.cmdline(':', cmdline)
