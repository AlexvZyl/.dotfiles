local u = require 'alex.utils'

require('noice').setup {
    cmdline = {
        format = {
            cmdline = { title = '', icon = '  ' },
            lua = { title = '', icon = ' 󰢱 ' },
            help = { title = '', icon = ' 󰋖 ' },
            input = { title = '', icon = '  ' },
            filter = { title = '', icon = '  ' },
            search_up = { icon = '    ' },
            search_down = { icon = '    ' },
        },
    },
    views = {
        cmdline_popup = {
            border = {
                style = u.border_chars_outer_thin,
                padding = { 0, 1 },
            },
        },
    },
    lsp = {
        override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
        },
        signature = { enabled = false, view = 'virtualtext' },
    },
    presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
    },
}

-- Notifiactions
local notify = require 'notify'
notify.setup {
    fps = 60,
    level = 'ERROR',
}

vim.notify = notify
