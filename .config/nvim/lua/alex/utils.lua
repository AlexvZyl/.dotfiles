local M = {}

-- Get a table with the colors used in the gruvbox-material theme.
function M.get_gruvbox_material_palette()
    local configuration = vim.fn['gruvbox_material#get_configuration']()
    local palette = vim.fn['gruvbox_material#get_palette'](configuration.background, configuration.foreground, configuration.colors_override)
    return palette
end

-- Lua does not have a length function for tables...
function M.length(table)
    local count = 0
    for _, _ in ipairs(table) do
        count = count + 1
    end
    return count
end

return M
