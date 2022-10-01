----------------------------------
-- Load, init and setup plugins --
----------------------------------

-- Nvim-Tree.lua advises to do this at the start.
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

------------------
-- Git Conflict --
------------------

require 'git-conflict'.setup {

}

---------------------------
-- Trouble (diagnostics) --
---------------------------

require 'trouble'.setup {
    use_diagnostic_signs = true,
    position = 'right'
}

----------------
-- Rust tools --
----------------

-- local rt = require 'rust-tools'
-- 
-- rt.setup({
--   server = {
--     on_attach = function(_, bufnr)
--       -- Hover actions
--       vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
--       -- Code action groups
--       vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
--     end,
--   },
-- })

----------------
-- LSP colors --
----------------

require("lsp-colors").setup({
  Error = "#db4b4b",
  Warning = "#e0af68",
  Information = "#0db9d7",
  Hint = "#10B981"
})

----------------
-- Catppuccin --
----------------

-- latte, frappe, macchiato, mocha
vim.g.catppuccin_flavour = 'mocha'
require 'catppuccin' .setup {
    integrations = {
        gitsigns = true,
        leap = true,
        telescope = true,
        which_key = true,
        notify = true,
        treesitter_context = true,
    }
}

----------------
-- Auto pairs --
----------------

require 'nvim-autopairs'.setup {
    map_cr = false
}

-- Setup for COC.

local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')
npairs.setup({map_cr=false})

-- skip it, if you use another global object
_G.MUtils= {}

-- old version
-- MUtils.completion_confirm=function()
  -- if vim.fn["coc#pum#visible"]() ~= 0 then
    -- return vim.fn["coc#_select_confirm"]()
  -- else
    -- return npairs.autopairs_cr()
  -- end
-- end

-- new version for custom pum
MUtils.completion_confirm=function()
    if vim.fn["coc#pum#visible"]() ~= 0  then
        return vim.fn["coc#pum#confirm"]()
    else
        return npairs.autopairs_cr()
    end
end

remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})

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
            local s = " "
            for e, n in pairs(diagnostics_dict) do
                if e == 'error' then
                    s = s .. '  ' .. n
                elseif e == 'warning' then
                    s = s .. ' ' .. n
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
-- Gitsigns --
--------------

-- Currently using this to get the git diag.
-- Using COC to display it.
-- Displaying git signs displays the results wrong...
require 'gitsigns'.setup {
    signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '│' },
        topdelete    = { text = '│' },
        changedelete = { text = '│' }
    },
    signcolumn = false,
    numhl = false
}

-------------------
-- Lualine setup --
-------------------

-- Show git status.
local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed
        }
    end
end

-- Get the OS to display in Lualine.
-- Just gonna hard code Arch for now.
local function get_os()
    -- return '  '
    return 'Archlinux  '
    -- return '  '
    -- return 'Windows  '
    -- return '  '
    -- return 'Debian  '
end

-- Get the lsp of the current buffer, when using native lsp.
local function get_native_lsp()
    local msg = 'None' 
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return msg
end

-- Get the lsp of the current buffer, when using coc.
local function get_coc_lsp()
    local services = vim.fn.CocAction('services')
    local current_lang = vim.api.nvim_buf_get_option(0, 'filetype')
    for _, lsp in pairs(services) do
        for _, lang in pairs(lsp['languageIds']) do
            if lang == current_lang then
                return lsp['id']
            end
        end
    end
    return 'None'
end

-- Get the status of the LSP.
local function get_coc_lsp_status()
    local current_lsp = get_coc_lsp()
    if current_lsp == 'None' then
        return ''
    end
    local services = vim.fn.CocAction('services')
    for _, lsp in pairs(services) do
        if lsp['id'] == current_lsp then
            return lsp['state']
        end
    end
    return ''
end

-- Display the lsp status, otherwise display none.
-- Making 'none' lower case here so that it fits in with the
-- way coc displays status.
local function get_coc_lsp_compact()
    local lsp_status = get_coc_lsp_status()
    if lsp_status == '' then
        return 'none'
    end
    return lsp_status
end

-- Required to properly set the colors.
local get_color = require 'lualine.utils.utils'.extract_highlight_colors

require 'lualine'.setup {
    sections = {
        lualine_a = {
            {
                'mode',
                icon = { '' },
            },
        },
        lualine_b = { 
            {
                'branch',
                icon = {
                    '',
                    color = { fg = get_color('Orange', 'fg') },
                },
            },
            {
                'filename' ,
                symbols = {
                    modified = '',
                    readonly = '',
                },
                icon = {
                    '',
                    color = { fg = get_color('Orange', 'fg') },
                },
            },
        },
        lualine_c = { 
            {
                'diff', 
                source = diff_source, 
                symbols = { 
                    added = ' ', 
                    modified = ' ', 
                    removed = ' '
                },
                separator = '',
            }, 
            { 
                'diagnostics', 
                sources = { 'coc' }, 
                separator = '',
                symbols = { 
                    error = ' ', 
                    warn = ' ', 
                    info = ' ', 
                    hint = ' ',
                },  
                diagnostics_color = {
                    error = { fg=get_color('Red', 'fg')    }, 
                    warn =  { fg=get_color('Yellow', 'fg') },
                    info =  { fg=get_color('Blue', 'fg')   },
                    hint =  { fg=get_color('Green', 'fg')  },
                }, 
                colored = true,
            },
        },
        lualine_x = {  
            {
                'filetype',
                icon = {
                    align = 'left'         
                }
            },
        },
        lualine_y = { 
            {
                get_coc_lsp_compact,
                icon = {
                    '  LSP',
                    align = 'left',
                    color = { 
                        fg = get_color('Orange', 'fg'), 
                        gui = 'bold' 
                    }
                } 
            },
        },
        lualine_z = { 
            { 
                'location',
                icon = {
                    '',
                    align = 'left',
                    color = { fg = get_color('Black', 'fg') },
                }
            },
            {
                'progress',
                icon = {
                    '',
                    align = 'left',
                    color = { fg = get_color('Black', 'fg') },
                }
            }
        },    
    },
    options = { 
        disabled_filetypes = { "startify" },
        globalstatus = true,
        section_separators = { left ='', right = '' },
        component_separators = { left = '', right = ''},
    },
    extensions = {
        "toggleterm",
        "nvim-tree"
    }
}

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

-------------------------------
-- Integrate COC with notify --
-------------------------------

local coc_status_record = {}

function coc_status_notify(msg, level)
  local notify_opts = { title = "LSP Status", timeout = 500, hide_from_history = true, on_close = reset_coc_status_record }
  -- if coc_status_record is not {} then add it to notify_opts to key called "replace"
  if coc_status_record ~= {} then
    notify_opts["replace"] = coc_status_record.id
  end
  coc_status_record = vim.notify(msg, level, notify_opts)
end

function reset_coc_status_record(window)
  coc_status_record = {}
end

local coc_diag_record = {}

function coc_diag_notify(msg, level)
  local notify_opts = { title = "LSP Diagnostics", timeout = 500, on_close = reset_coc_diag_record }
  -- if coc_diag_record is not {} then add it to notify_opts to key called "replace"
  if coc_diag_record ~= {} then
    notify_opts["replace"] = coc_diag_record.id
  end
  coc_diag_record = vim.notify(msg, level, notify_opts)
end

function reset_coc_diag_record(window)
  coc_diag_record = {}
end

----------------------
-- Setup toggleterm --
----------------------

require 'toggleterm'.setup {
    on_open = function(term)
        vim.cmd("startinsert")
    end,
    direction = "float",
    size = 15,
    float_opts = {
        border = 'single',
        winblend = 0,
    }
}

----------------------------
-- BTop++ with toggleterm --
----------------------------

local Terminal  = require('toggleterm.terminal').Terminal
-- local btop = Terminal:new({ cmd = "btop --utf-force", hidden = true, direction = "float" })
local btop = Terminal:new({ cmd = "btop", hidden = true, direction = "float" })
-- local btop = Terminal:new({ cmd = "btm", hidden = true, direction = "float" })
function _btop_toggle()
  btop:toggle()
end
vim.api.nvim_set_keymap("n", "<C-B>", "<Cmd>lua _btop_toggle()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("t", "<C-B>", "<Cmd>lua _btop_toggle()<CR>", {noremap = true, silent = true})

--------------------------
-- Fish with toggleterm --
--------------------------

local Terminal  = require('toggleterm.terminal').Terminal
local fish = Terminal:new({ cmd = "fish", hidden = true, direction = "horizontal" })
function _fish_toggle()
  fish:toggle()
end
vim.api.nvim_set_keymap("n", "<F1>", "<Cmd>lua _fish_toggle()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("t", "<F1>", "<Cmd>lua _fish_toggle()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("v", "<F1>", "<Cmd>lua _fish_toggle()<CR>", {noremap = true, silent = true})

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

---------------------------
-- Configure tree sitter --
---------------------------

require 'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = { "c", "lua", "rust", "cpp", "julia", "python" },
    -- ensure_installed = {  },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    -- List of parsers to ignore installing (for "all")
    -- ignore_install = { "" },

    highlight = {

        -- `false` will disable the whole extension
        enable = true,

        -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
        -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
        -- the name of the parser)
        -- list of language that will be disabled
        -- disable = { "" },

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
}

------------------------------
-- Set Seperators (borders) --
------------------------------

--  vim.opt.fillchars = {
--    horiz = '━',
--    horizup = '┻',
--    horizdown = '┳',
--    vert = '┃',
--    vertleft  = '┫',
--    vertright = '┣',
--    verthoriz = '╋',
--  }

vim.opt.fillchars = {
  -- horiz = '―',
  -- horizup = '―',
  horiz = '⎯',
  horizup = '⎯',
  horizdown = '⎯',
  vert = ' ',
  vertleft  = ' ',
  vertright = ' ',
  verthoriz = ' ',
  eob =' ',
}
