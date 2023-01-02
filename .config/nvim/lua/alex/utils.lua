local M = {}

-- Lua does not have a length function for tables...
function M.length(table)
    local count = 0
    for _, _ in ipairs(table) do
        count = count + 1
    end
    return count
end

return M
