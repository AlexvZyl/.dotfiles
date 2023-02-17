------------------
-- Git Conflict --
------------------

require 'git-conflict'.setup {

}

--------------
-- Gitsigns --
--------------

local git_char = '│'
-- local git_char = '|'
-- local git_char = '┆'
-- local git_char = '╎'

-- Display git changes.
require 'gitsigns'.setup {
    signs = {
        add          = { text = git_char },
        change       = { text = git_char },
        delete       = { text = git_char },
        topdelete    = { text = git_char },
        changedelete = { text = git_char },
        untracked    = { text = git_char }
    },
    signcolumn = true,
    numhl = false
}

-------------
-- Lazygit --
-------------

vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
vim.g.lazygit_floating_window_corner_chars = { '╭', '╮', '╰', '╯' } -- customize lazygit popup window corner characters
vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

------------------
-- Git worktree --
------------------

require("git-worktree").setup({
    change_directory_command = "cd",
    update_on_change = true,
    update_on_change_command = "e .",
    clearjumps_on_change = true,
    autopush = false,
})

--------------
-- Diffview --
--------------

require 'diffview' .setup {
    enhanced_diff_hl = true
}
