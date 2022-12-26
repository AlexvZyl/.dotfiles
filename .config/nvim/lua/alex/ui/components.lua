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

----------------
-- Auto pairs --
----------------

require 'nvim-autopairs'.setup {
    map_cr = false
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

---------------
-- Dashboard --
---------------

local db = require('dashboard')

db.preview_file_height = 11
db.preview_file_width = 70
db.custom_center = {
    {
        icon = "  ",
		desc = 'New file      ',
		action = "enew",
    },
    {
        icon = '  ',
        desc = 'Recent files  ',
        action =  'Telescope oldfiles',
    },
    {
        icon = '  ',
        desc = 'Find file     ',
        action = 'Telescope find_files find_command=rg,--hidden,--files',
    },
    {
        icon = '  ',
        desc = 'Find word     ',
        action = 'Telescope live_grep',
    },
    {
		icon = "  ",
		desc = "Update plugins",
		action = "PackerSync",
	},
}

db.custom_header = {
    '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
    '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
    '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
    '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
    '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
    '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
}

db.custom_footer = {
    'ﯦ  Dala what you must.'
}

-- Default sizes.
local header_height = 6
local center_height = 9
local footer_height = 1

-- Extra padding.
local header_extra_padding = 1
local center_extra_padding = 0
local footer_extra_padding = 0

-- Get window height in rows.
local win_height = vim.fn.winheight('%')
local padding = (win_height - header_height - center_height - footer_height) / 4

-- Calculate and set padding for each section.
db.header_pad = padding - header_extra_padding
db.center_pad = padding - center_extra_padding
db.footer_pad = padding - footer_extra_padding


---------------
-- Scrollbar --
---------------

-- require 'scrollbar'.setup {
    -- show_in_active_only = true,
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
    use_treesitter_scope = false,
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

-- Timeout.
vim.cmd('set timeoutlen =1000')

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
-- Load extensions.
ts.load_extension 'notify'
ts.load_extension 'lazygit'
ts.load_extension 'git_worktree'

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
    auto_reload_on_write = true,
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    reload_on_bufenter = true,
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
    git = {
        ignore = false
    }, 
    renderer = {
        indent_markers = {
            enable = true
        }
    },
    diagnostics = {
        enable = true
    }
}

------------------
-- Image Viewer --
------------------

-- require 'hologram'.setup {
--    auto_display = true
-- }

-----------
-- Noice --
-----------

-- require "noice".setup {
--     lsp = {
--         -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
--         override = {
--           ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
--           ["vim.lsp.util.stylize_markdown"] = true,
--           ["cmp.entry.get_documentation"] = true,
--         },
--     },
--     -- you can enable a preset for easier configuration
--     presets = {
--         bottom_search = true, -- use a classic bottom cmdline for search
--         command_palette = true, -- position the cmdline and popupmenu together
--         long_message_to_split = true, -- long messages will be sent to a split
--         inc_rename = false, -- enables an input dialog for inc-rename.nvim
--         lsp_doc_border = false, -- add a border to hover docs and signature help
--     },
-- }
