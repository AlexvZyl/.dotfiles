------------------
-- Git Conflict --
------------------

require('git-conflict').setup {}

--------------
-- Gitsigns --
--------------

local git_char = '│'
-- local git_char = '▕'
-- local git_char = '▏'
-- local git_char = '|'
-- local git_char = '┆'
-- local git_char = '╎'

-- Display git changes.
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

------------------
-- Git worktree --
------------------

require('git-worktree').setup {
    change_directory_command = 'cd',
    update_on_change = true,
    update_on_change_command = 'e .',
    clearjumps_on_change = true,
    autopush = false,
}

--------------
-- Diffview --
--------------

require('diffview').setup {
    enhanced_diff_hl = true,
}
