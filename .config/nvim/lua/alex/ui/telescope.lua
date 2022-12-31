local ts = require 'telescope'
local palette = require 'alex.utils'.get_gruvbox_material_palette()

-- Setup.
local border_chars_none = { " ", " ", " ", " ", " ", " ", " ", " " }
local border_chars_single_round = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
local border_chars_single_thick = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" }
local border_chars_experimental = { " ", "⎹", " ", " ", " ", " ", " ", " " }

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
        winblend = 0
    }
})

-- Load extensions.
ts.load_extension 'notify'
ts.load_extension 'lazygit'
ts.load_extension 'git_worktree'
ts.load_extension 'live_grep_args'
