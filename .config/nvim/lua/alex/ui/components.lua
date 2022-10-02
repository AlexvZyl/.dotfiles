----------------------------------
-- Load, init and setup plugins --
----------------------------------

-- Nvim-Tree.lua advises to do this at the start.
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

----------------------
-- Find and Replace --
----------------------

-- Allow FAR to undo.
vim.cmd('let g:far#enable_undo=1')

---------------------------
-- Trouble (diagnostics) --
---------------------------

require 'trouble'.setup {
    use_diagnostic_signs = true,
    position = 'right'
}

----------------
-- Auto pairs --
----------------

require 'nvim-autopairs'.setup {
    map_cr = false
}

----------------
-- Bufferline --
----------------

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
        diagnostics = "coc",
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = ""
            for e, n in pairs(diagnostics_dict) do
                if e == 'error' then
                    s = s .. '  '
                elseif e == 'warning' then
                    s = s .. ' '
                end
            end
            return s
        end,
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Directory",
                text_align = "center"
            }
        },
        separator_style = "padded_slant",
    }
}

----------
-- Leap --
----------

local leap = require 'leap'
leap.setup {

}
leap.set_default_keymaps(true)

----------------
-- Illuminate --
----------------

require 'illuminate'.configure {
    under_cursor = false,
    delay = 500,
    filetypes_denylist = {
        'startify',
        'NvimTree'
    }
}

-------------
-- Incline --
-------------

-- Get the buffer's filename.
local function get_file_from_buffer(buf)
    local bufname = vim.api.nvim_buf_get_name(buf)
    local res = bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No Name]'
    return res
end

-- Custom incline rendering.
local function render_incline(render_props)
    return {
        {
            get_file_from_buffer(render_props.buf),
            -- guibg = 'None',
            gui = 'italic',
            blend = 0,
        }
    }
end

require 'incline'.setup {
    render = render_incline,
    window = {
        padding = 1,
        padding_char = " ",
        margin = {
            horizontal = 0,
            vertical = 0
        },
        placement = {
            horizontal = 'right',
            vertical = 'bottom'
        },
        options = {
            signcolumn = 'no',
        },
    },
    hide = {
        focused_win = true
    }
}

-------------
-- Sartify --
-------------

-- Setup startify.
vim.cmd([[
    let g:startify_custom_header =
              \ 'startify#center(startify#fortune#cowsay())'
    let g:startify_lists = [
        \ { 'type': 'sessions',  'header': ['   Sessions']       },
        \ { 'type': 'dir',       'header': ['   Local Recents']       },
        \ { 'type': 'files',     'header': ['   Global Recents']         },
    \ ]
    let g:startify_files_number = 15
    " TODO!
    " let g:startify_custom_footer = [ '***' ]
]])

---------------
-- Scrollbar --
---------------

-- require 'scrollbar'.setup {
--     show_in_active_only = true,
--     set_highlights = false,
--     marks = {
--         Search = { color = 'Orange' },
--         Error = { color = 'Red' },
--         Warn = { color = 'Yellow' },
--         Info = { color = 'Blue' },
--         Hint = { color = 'Green' },
--         Misc = { color = 'Purple' }
--     }
-- } 

--------------
-- Zen mode --
--------------

require 'true-zen'.setup {
    modes = {
        ataraxis = {
            shade = 'dark',
            left = {
                hidden_number = false,
                hidden_relativenumber = false,
                hidden_signcolumn = "no",
                shown_number = true,
                shown_relativenumber = true,
                shown_signcolumn = "yes"
            }
        }
    },
   integrations = {
        lualine = true
    },
}

---------------------
-- Setup neoscroll --
---------------------

require 'neoscroll'.setup {
    erasing_function = 'quadratic'
}
local t = { }
t['<C-u>'] = {'scroll', {'-vim.wo.scroll * 2', 'true', '400', nil}}
t['<C-d>'] = {'scroll', { 'vim.wo.scroll * 2', 'true', '400', nil}}
require 'neoscroll.config'.set_mappings(t)

-----------------
-- Indentation --
-----------------

require 'indent_blankline'.setup {
    show_end_of_line = true,
    show_current_context = true,
    show_current_context_start = false,
    filetype_exclude = { 'NvimTree', 'startify' },
    use_treesitter = false,
    use_treesitter_scope = true,
    -- context_char = '┃',
    context_char = '│',
    -- char = '│',
    -- char = '',
    -- ['|', '¦', '┆', '┊']
    char = '┆',
}

---------------------
-- Formatter setup --
---------------------

-- Todo.
-- require 'formatter'.setup {}

---------------------
-- Setup which-key --
---------------------

require 'which-key'.setup {

}

---------------------
-- Setup telescope --
---------------------

local ts = require 'telescope'
ts.setup({
    defaults = {
        sort_mru = true,
        sorting_strategy = 'ascending',
        layout_config = {
            prompt_position = 'top'
        }
    }
})
ts.load_extension 'notify'
ts.load_extension 'lazygit'

---------------------------------
-- Setup default notifications --
---------------------------------

local notify = require 'notify'
notify.setup {}
vim.notify = notify

---------------
-- Nvim tree --
---------------

require 'nvim-tree'.setup {
    view = {
        hide_root_folder = false,
        signcolumn = 'no',
        mappings = {
            list = {
                -- Allow moving out of the explorer.
                { key = "<C-i>", action = "toggle_file_info" },
                { key = "<C-k>", action = "" }
            }
        },
        width = 40
    },
    auto_reload_on_write = true,
    git = {
        ignore = false
    },
    sync_root_with_cwd = true,
    renderer = {
        indent_markers = {
            enable = true
        }
    },
    diagnostics = {
        enable = true
    },
}
