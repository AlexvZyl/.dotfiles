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

-----------------
-- Indentation --
-----------------

require 'indent_blankline'.setup {
    show_end_of_line = true,
    show_current_context = true,
    show_current_context_start = false,
    filetype_exclude = { 'NvimTree', 'startify', 'dashboard' },
    use_treesitter = false,
    use_treesitter_scope = false,
    context_char = '│',
    char = '┆',
}

---------------------
-- Setup which-key --
---------------------

require 'which-key'.setup {

}

-- Timeout.
vim.cmd('set timeoutlen =1000')

---------------------------------
-- Setup default notifications --
---------------------------------

local notify = require 'notify'
notify.setup {
    fps = 60,
    level = "ERROR"
}
vim.notify = notify

-----------
-- Noice --
-----------

require "noice".setup {
    cmdline = {
        format = {
        }
    },
    lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
    },
    -- you can enable a preset for easier configuration
    presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
    },
}

---------------
-- Colorizer --
---------------

require 'colorizer' .setup {
    user_default_options = {
        mode = 'virtualtext',
        RRGGBB = true,
        RRGGBBAA = true,
        names = false,
        RGB = false,
        virtualtext = ' ',
    }
}

----------
-- Pets --
----------

require 'pets' .setup {
    row = 3, -- the row (height) to display the pet at (must be at least 1)
    col = 0, -- the column to display the pet at (set to high number to have it stay still on the right side)
    speed_multiplier = 1, -- you can make your pet move faster/slower. If slower the animation will have lower fps.
    default_pet = "cat", -- the pet to use for the PetNew command
    default_style = "brown", -- the style of the pet to use for the PetNew command
    random = false, -- wether to use a random pet for the PetNew command, ovverides default_pet and default_style
    death_animation = false, -- animate the pet's death, set to false to feel less guilt
}

