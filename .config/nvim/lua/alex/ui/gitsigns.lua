local git_char = '│'
require('gitsigns').setup {
    signs = {
        add = { text = git_char },
        change = { text = git_char },
        delete = { text = git_char },
        topdelete = { text = git_char },
        changedelete = { text = git_char },
        untracked = { text = git_char },
    },
    signcolumn = true,
    numhl = false,
}
