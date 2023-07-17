local cmp = require 'cmp'
local u = require 'alex.utils'

-- Format the completion menu. Yes, I am that pedantic.
local function format(_, item)
    local MAX_LABEL_WIDTH = 55
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

local formatting = {
    fields = { 'kind', 'abbr' },
    format = format,
}

local window = {
    completion = cmp.config.window.bordered {
        scrollbar = true,
        winhighlight = 'Normal:Pmenu,FloatBorder:SpecialCmpBorder,CursorLine:PmenuSel,Search:None',
        --border = u.border_chars_outer_thin,
        border = u.border_chars_cmp_items,
        col_offset = -1,
        side_padding = 0,
    },
    documentation = cmp.config.window.bordered {
        winhighlight = 'Normal:Pmenu,FloatBorder:SpecialCmpBorder,CursorLine:PmenuSel,Search:None',
        scrollbar = true,
        --border = u.border_chars_outer_thin,
        border = u.border_chars_cmp_doc,
    },
}

window.documentation.max_height = 18
window.documentation.max_width = 80
window.documentation.side_padding = 1

cmp.setup {
    formatting = formatting,
    window = window,
}
