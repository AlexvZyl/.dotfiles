-- Initial setup.
require 'nordic' .setup {
    bright_border = true,
	telescope = {
		style = 'flat',
	},
	bold_keywords = false,
	italic_comments = true,
	transparent_bg = false,
    cursorline = {
        theme = 'dark',
        bold = false
    },
    noice = {
        style = 'classic'
    }
}

-- Overrides.
local p = require 'nordic.colors'
local override = {
    PopupNormal = {
        bg = p.bg_dark,
    },
    PopupBorder = {
        bg = p.bg_dark,
        fg = p.grey1
    },
    Pmenu = {
        link = 'PopupNormal'
    },
    PmenuSel = {
        bg = p.yellow.base,
        fg = p.black,
        bold = true
    },
    PmenuBorder = {
        link = 'PopupBorder'
    },
    PmenuDocBorder = {
        bg = p.bg_dark,
        fg = p.grey1
    },
    TelescopePromptBorder = {
        bg = p.grey1,
        fg = p.grey1
    },
    TelescopePreviewBorder = {
        bg = p.bg_dark,
        fg = p.grey1
    },
    TelescopeResultsBorder = {
        bg = p.bg_dark,
        fg = p.grey1
    },
    TelescopeSelection = {
        bg = p.grey0
    },
    TelescopeSelectionCaret = {
        bg = p.grey0
    },
    NormalFloat = {
        bg = p.bg_dark
    },
    FloatBorder = {
        bg = p.bg_dark,
    },
    NoiceCmdlineIcon = {
        bg = p.bg_dark
    },
    NoiceCmdlinePopupBorder = {
        fg = p.cyan.base
    },
    SagaBorder = {
        bg = p.bg_dark,
        fg = p.grey1
    },
    SagaNormal = {
        bg = p.bg_dark
    },

    CmpItemAbbrDeprecated = { fg = p.grey4},
    CmpItemAbbrMatch = { fg = p.yellow.bright, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = p.yellow.bright, bold = true },

    CmpItemKindField = { link = '@field' },
    CmpItemKindProperty = { link = '@proprty' },
    CmpItemKindEvent = { link = 'Type' },

    CmpItemKindText = { fg = p.grey4 },
    CmpItemKindEnum = { link = 'Type' },
    CmpItemKindKeyword = { link = 'Keyword' },

    CmpItemKindConstant = { link  = 'Constant' },
    CmpItemKindConstructor = { link = 'Function'},
    CmpItemKindReference = { link = 'Variable' },

    CmpItemKindFunction = { link = 'Function' },
    CmpItemKindStruct = { link = 'Type' },
    CmpItemKindClass = { link = 'Type' },
    CmpItemKindModule = { link = 'Macro' },
    CmpItemKindOperator = { link = 'Operator' },

    CmpItemKindVariable = { link = '@variable' },
    CmpItemKindFile = { fg = p.blue1 },

    CmpItemKindUnit = { link = 'Constant' },
    CmpItemKindSnippet = { },
    CmpItemKindFolder = { fg = p.yellow.dark },

    CmpItemKindMethod = { link = 'Function' },
    CmpItemKindValue = { link = 'Constant' },
    CmpItemKindEnumMember = { link = 'Type' },

    CmpItemKindInterface = { link = 'Type' },
    CmpItemKindColor = { link = 'Constant' },
    CmpItemKindTypeParameter = { link = 'Type' },

}
require 'nordic' .setup {
    override = override
}

-- Load the scheme.
vim.cmd.colorscheme 'nordic'

vim.cmd([[highlight DiagnosticShowBorder guibg=]] .. p.bg_dark .. " guifg=" .. p.grey1)
vim.cmd([[highlight SagaNormal guibg=]] .. p.bg_dark)
