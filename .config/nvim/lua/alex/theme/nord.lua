-------------
-- Nordfox --
-------------

-- Get the base nord colors.
local np = require 'alex.theme.utils' .get_nord_palette()
-- Colors provided by nordfox.
local nf = require 'nightfox.palette' .load 'nordfox'

-- Theme adjustments.
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

        -- Keep these neutral.
        variable = np.white0,
        bracket = np.white0,
        number = np.white0,
        field = np.blue1,

        -- Functions.
        func = nf.orange.bright,

        -- Dim but readable.
        comment = np.gray4,

        -- For `self` and macros.
        builtin0 = nf.magenta.bright,
        preproc = nf.magenta.bright, -- Macros.

        -- Language keywords.
        keyword = np.red,
        conditional = np.red,

        -- Plus, minus, arrow.
        operator = nf.orange.bright,

        -- Srtings.
        string = np.green,

        -- Constants and prepcocessor?
        const = np.blue2,

        -- Types.
        type = np.yellow,
        builtin1 = np.yellow,

        -- Unknown things.
        ident = np.black,
        builtin2 = np.black,
        statement = np.black,
        regex = np.black,
    }
}

-- Set custom highlight groups.
local function set_nord_hlgroups()

    -- Nvim tree.
    vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = nf.yellow.dim })

    -- Telescope.
    vim.api.nvim_set_hl(0, "TelescopeTitle", { bg = np.orange, fg = np.black })
    vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = np.gray1 })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = np.gray1  })
    vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = np.black })
    vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = np.black })
    vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = np.gray1, fg = np.white2 })
    vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { fg = nf.yellow.bright })
    vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = np.black })
    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = np.black })

    -- Dashboard.
    vim.api.nvim_set_hl(0, "DashboardHeader", { fg = np.yellow })
    vim.api.nvim_set_hl(0, "DashboardFooter", { fg = np.cyan})
    vim.api.nvim_set_hl(0, "DashboardCenter", { fg = np.green })

    -- IndentBlankline.
    vim.api.nvim_set_hl(0, "IndentBlankLineContextChar", { fg = np.gray4 })
    vim.api.nvim_set_hl(0, "IndentBlankLineChar", { fg = np.gray3 })

    -- Cursor.
    vim.api.nvim_set_hl(0, "CursorLine", { bg = np.gray1 })

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
   types = "NONE",
   conditionals = "NONE",
   constants = "NONE",
   functions = "NONE",
   numbers = "NONE",
   operators = "NONE",
   strings = "italic",
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
