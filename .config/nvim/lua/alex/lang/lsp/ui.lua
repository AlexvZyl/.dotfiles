--------------
-- LSP Saga --
--------------

local keymap = vim.keymap.set
local saga = require('lspsaga')

-- Configs.
saga.init_lsp_saga {
    code_action_lightbulb = {
        enable = false
    },
    border_style = 'single'
}

-- Change highlight groups.

-- Below is the exmaple key mapping given on the GitHub page.

-- Lsp finder find the symbol definition implement reference
-- if there is no implement it will hide
-- when you use action in finder like open vsplit then you can
-- use <C-t> to jump back
keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })

-- Code action
keymap({"n","v"}, "ca", "<cmd>Lspsaga code_action<CR>", { silent = true })

-- Rename
keymap("n", "rr", "<cmd>Lspsaga rename<CR>", { silent = true })

-- Peek Definition
-- you can edit the definition file in this flaotwindow
-- also support open/vsplit/etc operation check definition_action_keys
-- support tagstack C-t jump back
keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true })

-- Show docs.
keymap("n", "gD", "<cmd>Lspsaga hover_doc<CR>", { silent = true })

-- Show line diagnostics
keymap("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })

-- Show cursor diagnostic
keymap("n", "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true })

-- Diagnsotic jump can use `<c-o>` to jump back
keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })
keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })

-- Only jump to error
keymap("n", "[E", function()
  require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { silent = true })
keymap("n", "]E", function()
  require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { silent = true })

-- Outline
keymap("n","<leader>o", "<cmd>LSoutlineToggle<CR>",{ silent = true })

-- Hover Doc
keymap("n", "K", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })

-- Float terminal
keymap("n", "<A-d>", "<cmd>Lspsaga open_floaterm<CR>", { silent = true })
-- if you want pass somc cli command into terminal you can do like this
-- open lazygit in lspsaga float terminal
keymap("n", "<A-d>", "<cmd>Lspsaga open_floaterm lazygit<CR>", { silent = true })
-- close floaterm
keymap("t", "<A-d>", [[<C-\><C-n><cmd>Lspsaga close_floaterm<CR>]], { silent = true })

-- End of example keymap.

-- Set colors (in vim).
-- highlight link LspSagaFinderSelection Search
-- highlight link LspSagaFinderSelection guifg='#ff0000' guibg='#00ff00' gui='bold'

-- Get the color palette.
local palette = require 'alex.utils'.get_gruvbox_material_palette()
local border_color = palette.orange[1]
vim.cmd('highlight! DefinitionBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! LspSagaLspFinderBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! LspSagaRenameBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! LspSagaDiagnosticBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! LspSagaHoverBorder guibg=NONE guifg=' .. border_color)
vim.cmd('highlight! LspSagaCodeActionBorder guibg=NONE guifg=' .. border_color)


