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

-- Get the color palette.
local palette = require 'alex.utils'.get_gruvbox_material_palette()
local border_color = palette.orange[1]

-- Set the borders colors.
vim.cmd('highlight! DefinitionBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! LspSagaLspFinderBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! LspSagaRenameBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! LspSagaDiagnosticBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! LspSagaHoverBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! LspSagaCodeActionBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! FinderSpinnerBorder guibg=NONE guifg=' .. border_color)

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
