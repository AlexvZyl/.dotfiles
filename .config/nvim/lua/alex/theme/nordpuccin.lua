-- Wanted to use nordfox as a base for the colorscheme, but editing it seems buggy.
-- Instead, use catpuccin as a base.  Nordfox has lighter and darker versions of each color,
-- su still use that.

-- The official colors from the website (with one added dark color.)
local np = require 'alex.theme.utils'.get_nord_palette()
-- The colors provided by nordfox.
local nf = require 'alex.theme.utils'.get_nordfox_palette()
-- Use all nord colors?
local pure_nord = true

-- For settings.
local setup = {}

-- Version of catpuccin to use.
-- Frappe works best with the nord background.
local using = "frappe"
setup.flavour = using

-- Set the specific styles. Available styles:
-- bold, underline, undercurl, underdouble, underdotted, underdashed, 
-- strikethrough, reverse, inverse, italic, standout, nocombine, NONE
setup.styles = {
   comments     = { "italic" },
   strings      = { },
   keywords     = { },
   types        = { },
   conditionals = { },
   constants    = { },
   functions    = { },
   numbers      = { },
   operators    = { },
   variables    = { },
}

-- Integrations.
setup.integrations = {
    gitsigns            = true,
    leap                = true,
    telescope           = true,
    which_key           = true,
    notify              = true,
    treesitter_context  = true,
}

-- Override colors.
setup.color_overrides  = {}
-- Use catpuccin colors, with nord backgrounds.
setup.color_overrides[using] = {
    -- Backgrounds.
    base = np.gray0,
    mantle = np.black,
    crust = np.black,
}
-- Use all nord colors.  Catppuccin has more colors than nord, so have to combine
-- some of them into one color.
if pure_nord then
    -- Remappings.
    setup.color_overrides[using].text       = nf.white.dim
    setup.color_overrides[using].teal       = np.cyan
    setup.color_overrides[using].yellow     = nf.yellow.base
    setup.color_overrides[using].red        = nf.red.bright
    setup.color_overrides[using].blue       = np.blue2
    setup.color_overrides[using].green      = nf.green.base
    setup.color_overrides[using].maroon     = nf.white.dim
    -- Pinks.
    setup.color_overrides[using].mauve      = nf.magenta.bright
    setup.color_overrides[using].pink       = nf.magenta.bright
    -- Oranges.
    setup.color_overrides[using].peach      = nf.orange.bright
    setup.color_overrides[using].rosewater  = nf.orange.bright
    -- This is used for brackets.
    setup.color_overrides[using].flamingo   = nf.white.dim
    -- Grays.
    setup.color_overrides[using].surface0   = np.black
    setup.color_overrides[using].surface1   = np.gray2
    setup.color_overrides[using].surface2   = np.gray4
    -- Whites.
    setup.color_overrides[using].overlay0   = np.gray4
    setup.color_overrides[using].overlay1   = nf.black.base -- Unsure.
    setup.color_overrides[using].overlay2   = nf.white.dim  -- Commas, operators.
end

-- Custom highlight groups.
if pure_nord then
    setup.custom_highlights = function(_)
        return {
            -- Language override.
            ["@constant"] = { fg = nf.magenta.bright },
            ["Number"] = { fg = nf.magenta.bright },
            ["@keyword"] = { fg = nf.orange.base, style = { 'bold' } },
            ["@keyword.return"] = { fg = nf.orange.base, style = { 'bold' } },
            ["@keyword.function"] = { fg = nf.orange.base, style = { 'bold' } },
            ["@keyword.export"] = { fg = nf.orange.base, style = { 'bold' } },
            ["@keyword.operator"] = { fg = nf.orange.base, style = { 'bold' } },
            ["@conditional"] = { fg = nf.orange.base, style = { 'bold' } },
            ["@macro"] = { fg = nf.red.base, style = { 'bold' } },
            ["@preproc"] = { fg = nf.red.base, style = { 'bold' } },
            ["@attribute"] = { fg = nf.red.base, style = { 'bold' } },
            ["@operator"] = { fg = nf.blue.bright },
            ["@boolean"] = { fg = nf.magenta.bright },
            ["@variable.builtin"] = { fg = nf.magenta.bright, style = { 'italic' } },
            ["@namespace"] = { fg = nf.yellow.dim, style = { 'italic' } },
            -- Tree.
            ["NvimTreeFolderIcon"] = { fg = nf.yellow.dim },
            ["NvimTreeFolderName"] = { fg = np.blue1 },
            ["NvimTreeEmptyFolderName"] = { fg = np.blue1 },
            ["NvimTreeOpenedName"] = { fg = np.blue1 },
            ["NvimTreeRootFolder"] = { fg = nf.yellow.base },
            -- Cursorline.
            ["CursorLineNr"] = { fg = nf.orange.bright, style = { "bold" }},
            ["CursorLine"] = { bg = np.black, fg = "" },
            ["Visual"] = { bg = np.black},
            -- Dashboard.
            ["DashboardHeader"] = { fg = nf.yellow.base, style = { "bold" } },
            ["DashboardFooter"] = { fg = nf.cyan.bright, style = { "italic", "bold" } },
            ["DashboardCenter"] = { fg = nf.green.base },
            -- Indentblankline.
            ["IndentBlanklineContextChar"] = { fg = np.gray3 },
            ["IndentBlanklineChar"] = { fg = np.gray2 },
            -- Telescope.
            ["TelescopePromptNormal"] = { bg = np.gray1 },
            ["TelescopePromptBorder"] = { bg = np.gray1 },
            ["TelescopeResultsNormal"] = { bg = np.black },
            ["TelescopeResultsBorder"] = { bg = np.black },
            ["TelescopePreviewNormal"] = { bg = np.black },
            ["TelescopePreviewBorder"] = { bg = np.black },
            ["TelescopeTitle"] = { bg = nf.orange.base, fg = np.black, style = { 'bold' } },
            ["TelescopeSelection"] = { bg = np.gray1, fg = np.white0 },
            ["TelescopeSelectionCaret"] = { fg = nf.yellow.bright, bg = np.gray1, style = { "bold" } },
            -- Trouble.
            ["TroubleNormal"] = { bg = np.black },
            -- Babar,
            ["BufferCurrent"] = { fg = nf.white.dim, bg = np.gray0, style = { 'bold' } },
            ["BufferCurrentSign"] = { fg = nf.orange.bright, bg = np.gray0, style = { 'bold' } },
            ["BufferCurrentMod"] = { fg = nf.white.dim, bg = np.gray0, style = { 'bold' } },
            ["BufferVisible"] = { fg = nf.white.dim, bg = np.black },
            ["BufferVisibleSign"] = { fg = np.black, bg = np.black, style = { 'bold' } },
            ["BufferVisibleMod"] = { fg = nf.white.dim, bg = np.black },
            ["BufferVisibleError"] = { fg = nf.red.bright, bg = np.black },
        }
    end
end

-- Setup.
require 'catppuccin' .setup(setup)

-- Set the catpuccin theme that was overridden.
vim.cmd.colorscheme("catppuccin-" .. using)
