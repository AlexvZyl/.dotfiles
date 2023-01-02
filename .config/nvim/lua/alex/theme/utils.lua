local M = {}

-- Get a table with the colors used in the gruvbox-material theme.
function M.get_gruvbox_material_palette()
    local configuration = vim.fn['gruvbox_material#get_configuration']()
    local palette = vim.fn['gruvbox_material#get_palette'](configuration.background, configuration.foreground, configuration.colors_override)
    return palette
end

-- Get the Nord color palette with a few added colors.
-- name0 = darkest version.
function M.get_nord_palette()
    return {

        -- Added this color.
        black = "#191C24",

        -- The darker gray they use on the website.
        gray0 = "#242933",

        -- Polar Night.
        gray1 = "#2E3440",
        gray2 = "#3B4252",
        gray3 = "#434C5E",
        gray4 = "#4C566A",

        -- A light gray for comments.
        gray5 = "#60728A",

        -- Snow storm.
        white0 = "#D8DEE9",
        white1 = "#E5E9F0",
        white2 = "#ECEFF4",

        -- Frost.
        blue0 = "#5E81AC",
        blue1 = "#81A1C1",
        blue2 = "#88C0D0",
        cyan  = "#8FBCBB",

        -- Aurora.
        red     = "#BF616A",
        orange  = "#D08770",
        yellow  = "#EBCB8B",
        green   = "#A3BE8C",
        magenta = "#B48EAD"

    }
end

return M
