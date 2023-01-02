-------------
-- Nordfox --
-------------

-- Override hihglights.
local np = require 'alex.theme.utils'.get_nord_palette()
local palette = {
    -- Backgrounds.
    bg1 = np.gray0,
    bg0 = np.black,
    -- Foregrounds.
    fg0 = np.white0,
    fg1 = np.white0,
    fg2 = np.white0,
    fg3 = np.gray2,
    -- Selections.
    sel0 = np.gray2,
    sel1 = np.gray3,
}
local spec = {
    syntax = {
        comment = np.gray5
    }
}

-- Set the specific styles. Available styles:
-- bold
-- underline
-- undercurl	    curly underline
-- underdouble	    double underline
-- underdotted	    dotted underline
-- underdashed	    dashed underline
-- strikethrough
-- reverse
-- inverse		    same as reverse
-- italic
-- standout
-- nocombine	    override attributes instead of combining them
-- NONE
local styles = {
   comments = "italic",
   keywords = "bold",
   types = "bold",
   conditionals = "NONE",
   constants = "NONE",
   functions = "bold",
   numbers = "NONE",
   operators = "NONE",
   strings = "NONE",
   variables = "NONE",
}

-- Now setup.
require 'nightfox'.setup {
    options = { styles = styles },
    specs = { nordfox = spec },
    palettes = { nordfox = palette }
}

-- Debugging.
vim.cmd 'colorscheme nordfox'
