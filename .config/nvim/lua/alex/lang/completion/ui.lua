local cmp = require 'cmp'
local u = require 'alex.utils'
local cu = require 'alex.lang.completion.utils'

cmp.setup({

    -- Format UI.
    formatting = {
        format = cu.format
    },

    -- Popup window.
    window = {
        completion = cmp.config.window.bordered {
            winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel,Search:None",
            scrollbar = false,
            border = u.border_chars_outer_thin
        },
        documentation = cmp.config.window.bordered {
            winhighlight = "Normal:Pmenu,FloatBorder:PmenuDocBorder,CursorLine:PmenuSel,Search:None",
            scrollbar = false,
            border = u.border_chars_outer_thin
        },
    }

})
