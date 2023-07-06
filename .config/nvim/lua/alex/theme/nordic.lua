require('nordic').setup {
    bright_border = false,
    telescope = { style = 'flat' },
    bold_keywords = false,
    italic_comments = true,
    transparent_bg = false,
    noice = { style = 'flat' },
    cursorline = {
        theme = 'dark',
        bold = false,
        hide_unfocused = true,
    },
}

vim.cmd.colorscheme 'nordic'
