------------
-- Config --
------------

require 'bufferline'.setup {
    options = {
        indicator = {
            style = 'underline',
        },
        tab_size = 12, -- Minimum size.
        buffer_close_icon ='',
        modified_icon = '',
        max_name_length = 20,
        mode = "buffers",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = ''
            for e, n in pairs(diagnostics_dict) do
                if e == 'error' then
                    s = s .. '  '
                elseif e == 'warning' then
                    s = s .. '  '
                end
            end
            return s:sub(1, -2)
        end,
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Directory",
                text_align = "center"
            },
            {
                filetype = "Trouble",
                text = "Diagnostics",
                highlight = "Directory",
                text_align = "center"
            }
        },
        separator_style = 'padded_slant',
        custom_filter = function(buf_number, buf_numbers)
            if vim.bo[buf_number].filetype ~= 'nvimtree' then
                return true
            end
        end
    }
}
