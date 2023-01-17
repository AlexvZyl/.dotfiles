--------------
-- LSP Saga --
--------------

local ui = {
    theme = 'round',
    border = 'rounded',
    winblend = 15,
    title = false
}

require 'lspsaga' .setup {
    lightbulb = {
        enable = false
    },
    ui = ui,
    definition = {
        edit = '<C-e>',
        vsplit = '<C-v>',
        split = '<C-h>',
        quit = 'q',
    },
    -- This feature is a bit much imo.
    symbol_in_winbar = {
        enable = false,
        folder_level = 1,
        show_file = true,
        separator = '  '
    },
    diagnostic = {
        show_code_action = false
    }
}

---------------------------
-- Trouble (diagnostics) --
---------------------------

require 'trouble'.setup {
    padding = true,
    height = 11,
    use_diagnostic_signs = false,
    position = 'bottom',
    signs = {
        error = " ",
        warning = " ",
        hint = " ",
        information = " ",
        other = " "
    },
    auto_preview = false
}

-- Make trouble update to the current buffer.
vim.cmd [[ autocmd BufEnter * TroubleRefresh ]]
