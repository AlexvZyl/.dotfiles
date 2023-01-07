--------------
-- LSP Saga --
--------------

local saga = require 'lspsaga'

-- Configs.
saga.init_lsp_saga {
    code_action_lightbulb = {
        enable = false
    },
    border_style = 'rounded',
    saga_winblend = 20,
    definition_action_keys = {
        edit = '<C-e>',
        vsplit = '<C-v>',
        split = '<C-h>',
        quit = 'q',
    },
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
