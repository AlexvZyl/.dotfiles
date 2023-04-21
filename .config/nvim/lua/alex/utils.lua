local M = {}

-- Lua does not have a length function for tables...
function M.length(table)
    local count = 0
    for _, _ in ipairs(table) do
        count = count + 1
    end
    return count
end

-- Border characters.
M.border_chars_none = { " ", " ", " ", " ", " ", " ", " ", " " }
M.border_chars_outer_thick = { "▛", "▀", "▜", "▐", "▟", "▄", "▙", "▌" }
M.border_chars_outer_thin = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
M.border_chars_inner_thin = { " ", "▁", " ", "▏", " ", "▔", " ", "▕" }
M.border_chars_inner_thick = { " ", "▄", " ", "▌", " ", "▀", " ", "▐" }

M.border_chars_outer_thin_telescope = { "▔", "▕", "▁", "▏", "🭽", "🭾", "🭿", "🭼" }
M.border_chars_outer_thick_telescope = { "▀", "▐", "▄", "▌", "▛", "▜", "▟", "▙" }

return M
