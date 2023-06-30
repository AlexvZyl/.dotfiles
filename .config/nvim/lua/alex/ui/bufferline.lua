local offsets = {
    {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "center",
        highlight = 'BufferLineOffset',
        separator = true,
    }
}

local options = {
    offsets = offsets,
    buffer_close_icon = '',
    close_icon = '',
    diagnostics = 'nvim_lsp',
    color_icons = true,
    separator_style = { ' ', ' ' },
    indicator = { style = 'none' }
}

require 'bufferline' .setup { options = options }
