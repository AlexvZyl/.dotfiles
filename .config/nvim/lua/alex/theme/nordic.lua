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
    Pmenu = {
        bg = p.bg_dark
    },
    PmenuSel = {
        bg = p.yellow.base,
        fg = p.black,
        bold = true
    },
    PmenuBorder = {
        bg = p.bg_dark,
        fg = p.grey1
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
    }
}
require 'nordic' .setup {
    override = override
}

-- Load the scheme.
vim.cmd.colorscheme 'nordic'
