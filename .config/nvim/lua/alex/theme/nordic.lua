require 'nordic' .setup {
    -- theme = 'onedark',
	telescope = {
		-- Available styles: `classic`, `flat`.
		style = 'flat',
	},
	-- Enable bold keywords and operators.
	bold_keywords = false,
	-- Enable italicized comments.
	italic_comments = true,
	-- Enable general editor background transparency.
	transparent_bg = false,
	-- Override styling of any highlight group.
    -- (see next section for an example)
	override = {},
    cursorline = {
        theme = 'dark',
    },
    noice = {
        style = 'classic'
    },
}

-- Load the scheme.
vim.cmd.colorscheme 'nordic'
