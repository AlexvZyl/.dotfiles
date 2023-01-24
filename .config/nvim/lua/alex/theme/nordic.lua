-- Setup.
require 'nordic' .setup {
    telescope = {
        -- Available styles: `classic`, `flat`.
        style = 'flat'
    },
    syntax = {
        comments = {
            italic = true,
        },
        operators = {
            bold = true
        },
        keywords = {
            bold = true
        }
    }
}

-- Load the scheme.
vim.cmd.colorscheme 'nordic'
