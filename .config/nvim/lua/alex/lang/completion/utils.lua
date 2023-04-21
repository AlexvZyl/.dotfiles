local M = {}

-- Filter out the text.
M.filter_text = function (entry, _)
    local kind = require('cmp.types').lsp.CompletionItemKind[entry:get_kind()]
    return kind ~= 'Text'
end

-- Icons in the cmp menu.
M.kind_icons = {
    Text = " ",
    Method = " ",
    Function = " ",
    Constructor = " ",
    Field = " ",
    Variable = " ",
    Class = "ﴯ ",
    Interface = " ",
    Module = " ",
    Property = "ﰠ ",
    Unit = " ",
    Value = " ",
    Enum = " ",
    Keyword = " ",
    Snippet = " ",
    Color = " ",
    File = " ",
    Reference = " ",
    Folder = " ",
    EnumMember = " ",
    Constant = " ",
    Struct = " ",
    Event = " ",
    Operator = " ",
    TypeParameter = " "
}

-- Used for tabbing in cmp results.
M.has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

M.ELLIPSIS_CHAR = '…'
M.MAX_LABEL_WIDTH = 30

M.get_ws = function (max, len)
  return (" "):rep(max - len)
end

M.format = function(entry, item)

    -- Limit content width.
    local content = item.abbr
    if #content > M.MAX_LABEL_WIDTH then
        item.abbr = vim.fn.strcharpart(content, 0, M.MAX_LABEL_WIDTH) .. M.ELLIPSIS_CHAR
    else
        item.abbr = content .. M.get_ws(M.MAX_LABEL_WIDTH, #content)
    end

    -- Replace kind with icons.
    item.kind = M.kind_icons[item.kind] or '  '

    -- Remove gibberish.
    item.menu = nil

    return item

end

return M
