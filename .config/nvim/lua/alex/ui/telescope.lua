local ts = require 'telescope'
local u = require 'alex.utils'

-- Setup.
ts.setup {
    defaults = {
        sort_mru = true,
        sorting_strategy = 'ascending',
        layout_config = {
            prompt_position = 'top',
        },
        borderchars = {
            prompt = u.border_chars_outer_thin_telescope,
            results = u.border_chars_outer_thin_telescope,
            preview = u.border_chars_outer_thin_telescope,
        },
        border = true,
        multi_icon = '',
        entry_prefix = '   ',
        prompt_prefix = '   ',
        selection_caret = '  ',
        hl_result_eol = true,
        results_title = '',
        winblend = 0,
        wrap_results = true,
    },
}

-- Extensions.
ts.load_extension 'notify'
ts.load_extension 'git_worktree'
