-------------
-- Nordfox --
-------------

-- Override hihglights.
local np = require 'alex.theme.utils'.get_nord_palette()
local palette = {
    bg1 = np.gray0,
    bg0 = np.black,
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

vim.cmd 'colorscheme nordfox'
