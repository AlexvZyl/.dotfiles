-- Initial setup.
require('nordic').setup {
    bright_border = false,
    telescope = {
        style = 'flat',
    },
    bold_keywords = false,
    italic_comments = true,
    transparent_bg = false,
    cursorline = {
        theme = 'dark',
        bold = false,
    },
    noice = {
        style = 'classic',
    },
}

-- Overrides.
local p = require 'nordic.colors'
local override = {
    CursorLine = { bg = p.bg },
    CursorLineNr = { bold = false },

    PopupNormal = { bg = p.bg_dark },
    PopupBorder = { bg = p.bg_dark, fg = p.bg },
    Pmenu = { link = 'PopupNormal' },
    PmenuSel = { bg = p.grey0 },
    PmenuBorder = { link = 'PopupBorder' },

    NormalFloat = { bg = p.black1 },
    FloatBorder = { bg = p.black1, fg = p.black },

    NoiceCmdlineIcon = { bg = p.black1 },
    NoiceCmdlinePopupBorder = { fg = p.black },
    NoiceLspProgressTitle = { fg = p.yellow.base, bg = p.bg, bold = true },
    NoiceLspProgressClient = { fg = p.gray4, bg = p.bg },
    NoiceLspProgressSpinner = { fg = p.cyan.bright, bg = p.bg },
    NoiceFormatProgressDone = { bg = p.green.bright, fg = p.black },
    NoiceFormatProgressTodo = { bg = p.gray5, fg = p.black },
    NoiceCmdlineIconSearch = { bg = p.bg_dark, fg = p.yellow.base },
    NoiceCmdline = { bg = p.bg_dark, fg = p.fg },

    CmpItemKindTabNine = { fg = p.red.base },
    CmpItemKindCopilot = { fg = p.red.base },

    TelescopePreviewLine = { bg = p.gray0 },
    CopilotSuggestion = { fg = p.gray2 },
    NvimTreeWinSeparator = { fg = p.gray1, bg = p.bg },
    WinSeparator = { fg = p.black },

    DiagnosticUnderlineError = { undercurl = true, underline = false },
    DiagnosticUnderlineHint = { undercurl = true, underline = false },
    DiagnosticUnderlineInfo = { undercurl = true, underline = false },
    DiagnosticUnderlineWarn = { undercurl = true, underline = false },
    DiagnosticText = { bg = p.black1 },
}
require('nordic').setup { override = override }

-- Load the scheme.
vim.cmd.colorscheme 'nordic'
