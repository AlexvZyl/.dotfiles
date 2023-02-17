local ts = require 'telescope'

-- Setup.
local border_chars_none = { " ", " ", " ", " ", " ", " ", " ", " " }
ts.setup({
    defaults = {
        sort_mru = true,
        sorting_strategy = 'ascending',
        layout_config = {
            prompt_position = 'top'
        },
        borderchars = {
            prompt = border_chars_none,
            results = border_chars_none,
            preview = border_chars_none
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
