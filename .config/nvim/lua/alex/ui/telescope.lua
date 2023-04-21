local ts = require 'telescope'
local u = require 'alex.utils'

-- Setup.
ts.setup({
    defaults = {
        sort_mru = true,
        sorting_strategy = 'ascending',
        layout_config = {
            prompt_position = 'top'
        },
        borderchars = {
            prompt = u.border_chars_none,
            results = u.border_chars_none,
            preview = u.border_chars_none
        },
        border = true,
        prompt_prefix = '   ',
        hl_result_eol = true,
        results_title = "",
        winblend = 0,
        wrap_results = true
    }
})

-- Extensions.
ts.load_extension 'notify'
ts.load_extension 'lazygit'
ts.load_extension 'git_worktree'
