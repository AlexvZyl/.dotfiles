------------------
-- Git Conflict --
------------------

require 'git-conflict'.setup {

}

--------------
-- Gitsigns --
--------------

-- Currently using this to get the git diag.
-- Using COC to display it.
-- Displaying git signs displays the results wrong...
require 'gitsigns'.setup {
    signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '│' },
        topdelete    = { text = '│' },
        changedelete = { text = '│' }
    },
    signcolumn = false,
    numhl = false
}
