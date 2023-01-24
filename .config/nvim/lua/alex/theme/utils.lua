local M = {}

-- Get a table with the colors used in the gruvbox-material theme.
function M.get_gruvbox_material_palette()
    local configuration = vim.fn['gruvbox_material#get_configuration']()
    local palette = vim.fn['gruvbox_material#get_palette'](configuration.background, configuration.foreground, configuration.colors_override)
    return palette
end

return M
