-- The official colors from the website (with one added dark color.)
local np = require 'alex.theme.utils'.get_nord_palette()
-- The colors provided by nordfox.
local nf = require 'alex.theme.utils'.get_nordfox_palette()

-- Bufferline colors.
local function bufferline_colors()
    return {
        background          = { bg = np.black },
        separator           = { bg = np.black },
        separator_selected  = { bg = np.black },
        buffer_selected     = { bg = np.black },
        tab_close           = { bg = np.black },
        fill                = { bg = np.black }
    }
end


require 'bufferline'.setup {
    highlights = bufferline_colors,
    options = {
        indicator = {
            style = 'underline',
        },
        tab_size = 12, -- Minimum size.
        buffer_close_icon ='',
        close_icon = '',
        modified_icon = '',
        max_name_length = 20,
        mode = "buffers",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = ''
            for e, n in pairs(diagnostics_dict) do
                if e == 'error' then
                    s = s .. ' '
                elseif e == 'warning' then
                    s = s .. ' '
                end
            end
            return s:sub(1, -2)
        end,
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Type",
                text_align = "center",
            },
            {
                filetype = "Trouble",
                text = "Diagnostics",
                highlight = "Directory",
                text_align = "center"
            }
        },
        separator_style = 'slant',
        -- separator_style = {' ',' '},
        -- separator_style = {' ',' '},
        custom_filter = function(buf_number, buf_numbers)
            if vim.bo[buf_number].filetype ~= 'nvimtree' then
                return true
            end
        end
    }
}
