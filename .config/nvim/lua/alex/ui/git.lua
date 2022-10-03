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

-------------
-- Lazygit --
-------------

vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
vim.g.lazygit_floating_window_corner_chars = { '╭', '╮', '╰', '╯' } -- customize lazygit popup window corner characters
vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

------------
-- Neogit --
------------

require 'neogit'.setup {
    kind = 'floating'
}
