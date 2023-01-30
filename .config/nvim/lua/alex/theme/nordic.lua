require 'nordic' .setup {
	telescope = {
		-- Available styles: `classic`, `flat`.
		style = 'flat',
	},
	-- Enable bold keywords and operators.
	bold_keywords = true,
	-- Enable italicized comments.
	italic_comments = false,
	-- Enable general editor background transparency.
	transparent_bg = false,
	-- Override styling of any highlight group.
    -- (see next section for an example)
	override = {},
    cursorline = {
        bold = false,
        -- Avialable styles: 'dark', 'light'.
        theme = 'light'
    }
}

-- Load the scheme.
vim.cmd.colorscheme 'nordic'
