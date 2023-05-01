local cmp = require 'cmp'
local u = require 'alex.utils'

-- Format the completion menu.
-- Yes, I am that pedantic.
local function format(_, item)
    -- Utils.
    local MAX_LABEL_WIDTH = 50
    local function whitespace(max, len) return (' '):rep(max - len) end

    -- Limit content width.
    local content = item.abbr
    if #content > MAX_LABEL_WIDTH then
        item.abbr = vim.fn.strcharpart(content, 0, MAX_LABEL_WIDTH) .. '…'
    else
        item.abbr = content .. whitespace(MAX_LABEL_WIDTH, #content)
    end

    -- Replace kind with icons.
    item.kind = ' ' .. (u.kind_icons[item.kind] or u.kind_icons.Unknown) .. '│'

    -- Remove gibberish.
    item.menu = nil

    return item
end

-- Setup.
cmp.setup {

    -- Format UI.
    formatting = {
        fields = { 'kind', 'abbr' },
        format = format,
    },

    -- Popup window.
    window = {
        completion = cmp.config.window.bordered {
            winhighlight = 'Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel,Search:None',
            scrollbar = true,
            border = u.border_chars_outer_thin,
            col_offset = -1,
            side_padding = 0,
        },
        documentation = cmp.config.window.bordered {
            winhighlight = 'Normal:Pmenu,FloatBorder:PmenuDocBorder,CursorLine:PmenuSel,Search:None',
            scrollbar = true,
            border = u.border_chars_outer_thin,
            side_padding = 1, -- Not working?
        },
    },
}
