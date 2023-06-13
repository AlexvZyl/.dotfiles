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
    PopupBorder = { bg = p.bg_dark, fg = p.grey1 },
    Pmenu = { link = 'PopupNormal' },
    PmenuSel = { bg = p.grey0 },
    PmenuBorder = { link = 'PopupBorder' },
    PmenuDocBorder = { bg = p.bg_dark, fg = p.grey1 },
    NormalFloat = { bg = p.bg_dark },
    FloatBorder = { bg = p.bg_dark },
    NoiceCmdlineIcon = { bg = p.bg_dark },
    NoiceCmdlinePopupBorder = { fg = p.cyan.base },
    SagaBorder = { bg = p.bg_dark, fg = p.grey1 },
    SagaNormal = { bg = p.bg_dark },
    NoiceLspProgressTitle = { fg = p.yellow.base, bg = p.bg, bold = true },
    NoiceLspProgressClient = { fg = p.gray4, bg = p.bg },
    NoiceLspProgressSpinner = { fg = p.cyan.bright, bg = p.bg },
    NoiceFormatProgressDone = { bg = p.green.bright, fg = p.black },
    NoiceFormatProgressTodo = { bg = p.gray5, fg = p.black },
    CmpItemKindTabNine = { fg = p.red.base },
    CmpItemKindCopilot = { fg = p.red.base },
    TelescopePreviewLine = { bg = p.gray0 },
    CopilotSuggestion = { fg = p.gray2 },
    NvimTreeWinSeparator = { fg = p.gray1, bg = p.bg },
    WinSeparator = { fg = p.gray1 },
    WhichKeyBorder = { fg = p.gray1, bg = p.bg_dark },
}
require('nordic').setup { override = override }

-- Load the scheme.
vim.cmd.colorscheme 'nordic'

-- After, not sure what is happening here...
vim.cmd([[highlight DiagnosticShowBorder guibg=]] .. p.bg_dark .. ' guifg=' .. p.grey1)
vim.cmd([[highlight SagaNormal guibg=]] .. p.bg_dark)
