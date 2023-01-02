-------------
-- Nordfox --
-------------

-- Override hihglights.
local np = require 'alex.theme.utils' .get_nord_palette()
local nf = require 'nightfox.palette' .load 'nordfox'

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
        comment = np.gray5,
        keyword = np.red,
        func = np.cyan,
        variable = np.white0,
        field = np.blue1,
        bracket = np.white0,
        string = np.green,
        conditional = np.red,
        operator = np.orange,
        number = np.white0,
    }
}

-- Set custom highlight groups.
local function set_nord_hlgroups()
    vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = nf.yellow.dim })
end

-- Call when the colorscheme is being set.
local nord_augroup = vim.api.nvim_create_augroup("CustomNordHighlights", { clear = true } )
vim.api.nvim_create_autocmd("ColorScheme nordfox", {
    callback = set_nord_hlgroups,
    group = nord_augroup
})

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
   conditionals = "bold",
   constants = "bold",
   functions = "bold",
   numbers = "NONE",
   operators = "bold",
   strings = "italic,bold",
   variables = "NONE",
}

-- Now setup.
require 'nightfox'.setup {
    options = { styles = styles },
    specs = { nordfox = spec },
    palettes = { nordfox = palette },
}

-- Debugging.
vim.cmd 'colorscheme nordfox'
