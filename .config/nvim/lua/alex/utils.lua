local M = {}

function M.file_exists(file)
    local f = io.open(file, 'r')
    if f then
        io.close(f)
        return true
    else
        return false
    end
end

function M.length(table)
    local count = 0
    for _, _ in ipairs(table) do
        count = count + 1
    end
    return count
end

M.border_chars_none = { '', '', '', '', '', '', '', '' }
M.border_chars_empty = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
M.border_chars_tmux = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
M.border_chars_inner_thick = { ' ', '▄', ' ', '▌', ' ', '▀', ' ', '▐' }
M.border_chars_outer_thick = { '▛', '▀', '▜', '▐', '▟', '▄', '▙', '▌' }
M.border_chars_outer_thin = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' }
M.border_chars_inner_thin = { ' ', '▁', ' ', '▏', ' ', '▔', ' ', '▕' }
M.border_chars_outer_thin_telescope = { '▔', '▕', '▁', '▏', '🭽', '🭾', '🭿', '🭼' }
M.border_chars_outer_thick_telescope = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' }

M.bottom_thin = '▁'
M.top_thin = '▔'
M.left_thin = '▏'
M.right_thin = '▕'
M.left_thick = '▎'
M.right_thick = '🮇'
M.full_block = '█'
M.top_right_thin = '🭾'
M.top_left_thin = '🭽'
M.bottom_left_thin = '🭼'
M.bottom_right_thin = '🭿'

M.diagnostic_signs = {
    error = ' ',
    warning = ' ',
    info = ' ',
    hint = '󱤅 ',
    other = '󰠠 ',
}

M.kind_icons = {
    Text = ' ',
    Method = ' ',
    Function = '󰊕 ',
    Constructor = ' ',
    Field = ' ',
    Variable = ' ',
    Class = '󰠱 ',
    Interface = ' ',
    Module = '󰏓 ',
    Property = ' ',
    Unit = ' ',
    Value = ' ',
    Enum = ' ',
    EnumMember = ' ',
    Keyword = '󰌋 ',
    Snippet = '󰲋 ',
    Color = ' ',
    File = ' ',
    Reference = ' ',
    Folder = ' ',
    Constant = '󰏿 ',
    Struct = '󰠱 ',
    Event = ' ',
    Operator = ' ',
    TypeParameter = '󰘦 ',
    TabNine = '󰚩 ',
    Copilot = ' ',
    Unknown = ' ',
}

return M
