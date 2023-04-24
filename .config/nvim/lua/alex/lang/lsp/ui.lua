local u = require 'alex.utils'

--------------
-- LSP Saga --
--------------

local ui = {
    theme = 'round',
    border = u.border_chars_outer_thin,
    winblend = 5,
    title = false,
    diagnostic = '  ',
}

local lightbulb = {
    enable = false
}

local definition = {
    edit = '<C-e>',
    vsplit = '<C-v>',
    split = '<C-h>',
    quit = 'q',
}

local winbar = {
    enable = false,
    folder_level = 1,
    show_file = true,
    separator = '  '
}

local diagnostic = {
    show_code_action = false,
    on_insert = false
}

require 'lspsaga' .setup {
    lightbulb = lightbulb,
    ui = ui,
    definition = definition,
    symbol_in_winbar = winbar,
    diagnostic = diagnostic
}

---------------------------
-- Trouble (diagnostics) --
---------------------------

require 'trouble'.setup {
    padding = true,
    height = 11,
    use_diagnostic_signs = false,
    position = 'bottom',
    signs = u.diagnostic_signs,
    auto_preview = false
}

-- Make trouble update to the current buffer.
vim.cmd [[ autocmd BufEnter * TroubleRefresh ]]
