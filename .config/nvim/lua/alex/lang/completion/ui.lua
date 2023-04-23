local cmp = require 'cmp'
local u = require 'alex.utils'

-- Icons in the cmp menu.
local kind_icons = {
    Text = "  │",
    Method = "  │",
    Function = " 󰊕 │",
    Constructor = "  │",
    Field = "  │",
    Variable = "  │",
    Class = " 󰠱 │" ,
    Interface = "  │",
    Module = " 󰏓 │",
    Property = "  │" ,
    Unit = "  │",
    Value = "  │",
    Enum = "  │",
    EnumMember = "  │",
    Keyword = " 󰌋 │",
    Snippet = " 󰲋 │",
    Color = "  │",
    File = "  │",
    Reference = "  │",
    Folder = "  │",
    Constant = " 󰏿 │",
    Struct = " 󰠱 │",
    Event = "  │",
    Operator = "  │",
    TypeParameter = " 󰘦 │",
    Unknown = "  │"
}

local get_ws = function (max, len)
  return (" "):rep(max - len)
end

local MAX_LABEL_WIDTH = 50
local format = function(_, item)

    -- Limit content width.
    local content = item.abbr
    if #content > MAX_LABEL_WIDTH then
        item.abbr = vim.fn.strcharpart(content, 0, MAX_LABEL_WIDTH) .. '…'
    else
        item.abbr = content .. get_ws(MAX_LABEL_WIDTH, #content)
    end

    -- Replace kind with icons.
    item.kind = kind_icons[item.kind] or kind_icons.Unknown

    -- Remove gibberish.
    item.menu = nil

    return item

end

cmp.setup {

    -- Format UI.
    formatting = {
        fields = { 'kind', 'abbr' },
        format = format
    },

    -- Popup window.
    window = {
        completion = cmp.config.window.bordered {
            winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel,Search:None",
            scrollbar = true,
            border = u.border_chars_outer_thin,
            col_offset = -1,
            side_padding = 0
        },
        documentation = cmp.config.window.bordered {
            winhighlight = "Normal:Pmenu,FloatBorder:PmenuDocBorder,CursorLine:PmenuSel,Search:None",
            scrollbar = true,
            border = u.border_chars_outer_thin,
            side_padding = 1
        },
    }

}
