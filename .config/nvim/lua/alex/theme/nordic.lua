require('nordic').setup {
    bright_border = false,
    telescope = { style = 'flat' },
    bold_keywords = false,
    italic_comments = true,
    transparent_bg = false,
    noice = { style = 'flat' },
    swap_backgrounds = false,
    cursorline = {
        theme = 'dark',
        bold = false,
        bold_number = true,
        blend = 0.7
    },
}

vim.cmd.colorscheme 'nordic'
