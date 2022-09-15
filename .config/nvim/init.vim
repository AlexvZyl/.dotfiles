" -------
" PLUGINS
" -------

call plug#begin()

" Telecope.
Plug 'nvim-telescope/telescope.nvim'
" Telescope deps.
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'

" Gui.
Plug 'akinsho/toggleterm.nvim'
Plug 'rcarriga/nvim-notify'	
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'akinsho/bufferline.nvim'
Plug 'mhinz/vim-startify'
Plug 'b0o/incline.nvim'
Plug 'Pocco81/true-zen.nvim' " Zen mode!

" Programming experience.
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'mg979/vim-visual-multi'
Plug 'karb94/neoscroll.nvim'
Plug 'RRethy/vim-illuminate'
Plug 'windwp/nvim-autopairs'

" Motions.
Plug 'ggandor/leap.nvim'
" Leap deps.
Plug 'tpope/vim-repeat'

" Git.
Plug 'lewis6991/gitsigns.nvim' 
Plug 'sindrets/diffview.nvim'
Plug 'akinsho/git-conflict.nvim'

" Neovim helpers.
Plug 'folke/which-key.nvim'
Plug 'sudormrfbin/cheatsheet.nvim'

" Filesystem & Searching.
Plug 'kyazdani42/nvim-tree.lua'
Plug 'BurntSushi/ripgrep'
Plug 'brooth/far.vim'

" General langage.
Plug 'nvim-treesitter/nvim-treesitter'  " Syntax highlighting.
Plug 'preservim/nerdcommenter' " More commenting functions.
Plug 'tpope/vim-commentary'  " Allow commenting with <C-/>.
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'} " Main LSP.  Also adds git stuff.

" Language specific plugins.
Plug 'prabirshrestha/vim-lsp'
Plug 'JuliaEditorSupport/julia-vim'
Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': 'bash install.sh'}
Plug 'sumneko/lua-language-server' 
Plug 'simrat39/rust-tools.nvim'

" Themes.
Plug 'sainnhe/gruvbox-material' " My fav.
Plug 'catppuccin/nvim' " This one is nice.
Plug 'morhetz/gruvbox'
Plug 'folke/tokyonight.nvim'
Plug 'EdenEast/nightfox.nvim'
Plug 'sainnhe/everforest'
Plug 'sainnhe/edge'
Plug 'shaunsingh/nord.nvim'
Plug 'dracula/vim'
Plug 'joshdick/onedark.vim'

" Alternative motion plugin.
" Plug 'phaazon/hop.nvim'
" Still need to setup.
" Plug 'mhartington/formatter.nvim'
" For when I make the PR.
" Plug 'Alex-vZyl/toggleterm.nvim', {'tag' : 'v2.*'}
" Not yet ready.
" Plug 'petertriho/nvim-scrollbar'
" Image viewing.  Not set up currently. 
" Plug 'edluffy/hologram.nvim'

" Set the theme so that the plugins can have access to the colors.
call plug#end()

" Setup nefore plugins are loaded.
let g:ale_disable_lsp = 1

" The colorscheme has to be set here so that the plugings can access it.

" Has to be set before colorscheme is set.
if has('termguicolors')
    set termguicolors
end
syntax on

" Apply custom highlights on colorscheme change.
" Must be declared before executing ':colorscheme'.
augroup custom_highlights_gruvboxmaterial
  autocmd!
  " floating popups
  autocmd ColorScheme gruvbox-material 
  \       hi NvimTreeNormal      guibg=#181818 |
  \       hi NvimTreeEndOfBuffer guibg=#181818
augroup END

" Setup themes.
" let g:gruvbox_material_foreground = 'original'
let g:gruvbox_material_foreground = 'mix'
" let g:gruvbox_material_foreground = 'material'
let g:gruvbox_material_background = 'hard'
let background = 'dark'
let g:everforest_background = 'hard'
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_ui_contrast = 'low'
let g:gruvbox_material_disable_terminal_colors = 0
let g:gruvbox_material_statusline_style = 'default'

" Custom colors for gruvbox-material.
function! s:gruvbox_material_custom() abort
    " Init palette used.
    let l:palette = gruvbox_material#get_palette(g:gruvbox_material_background, g:gruvbox_material_foreground, {})
    call gruvbox_material#highlight('CursorLineNr', l:palette.orange, l:palette.none)
    call gruvbox_material#highlight('TabLineSel', l:palette.orange, l:palette.none)
endfunction
augroup GruvboxMaterialCustom
    autocmd!
    autocmd ColorScheme gruvbox-material call s:gruvbox_material_custom()
augroup END

" Apply the colorscheme.
colorscheme gruvbox-material

" ----------
" LUA CONFIG
" ----------

lua <<EOF

------------------
-- Git Conflict --
------------------

require 'git-conflict'.setup {

}

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
                    s = s .. ' ' .. n
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
    delay = 500
}

-------------
-- Incline --
-------------

-- Get the buffer's filename.
function get_file_from_buffer(buf)
    local bufname = vim.api.nvim_buf_get_name(buf)
    local res = bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No Name]'
    return res
end

-- Custom incline rendering.
function render_incline(render_props)
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
function get_os()
    -- return '  '
    return 'Archlinux  '
    -- return '  '
    -- return 'Windows  '
    -- return '  '
    -- return 'Debian  '
end

-- Required to properly set the colors.
local get_color = require'lualine.utils.utils'.extract_highlight_colors

require 'lualine'.setup {
    sections = {
        lualine_a = { 
            'mode', 
        },
        lualine_b = { 
            {
                'branch', 
                icon = '',
            },
            { 
                'filename' ,
                symbols = {
                    modified = '',
                    readonly = ' ',
                },
                icon = '',
            },
        },
        lualine_c = { 
            {
                'diff', 
                source = diff_source, 
                symbols = { 
                    -- added = ' ', 
                    -- modified = 'ﯽ ', 
                    -- removed = ' ' 
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
                    -- error = ' ', 
                    -- warn = ' ', 
                    -- info = ' ', 
                    -- hint = ' ',
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
            -- 'encoding',
            -- 'filesize', 
            'filetype'
        },
        lualine_y = { 
            'location',
            'progress',
        },
        lualine_z = { 
            get_os
        },    
    },
    options = { 
        disabled_filetypes = { "startify" },
        globalstatus = true,
        -- component_separators = { left = '', right = ''},
        section_separators = { left ='', right = '' },
        component_separators = { left = '', right = ''},
        -- section_separators = { left = '', right = ''},
        -- component_separators = { left = '', right = '' },
        -- section_separators = { left = '', right = '' },
        -- component_separators = { left = '', right = '' },
        -- section_separators = { left = '┃', right = '┃' },

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

-----------------------------
-- Lazygit with toggleterm --
-----------------------------
 
local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })
function _lazygit_toggle()
  lazygit:toggle()
end
vim.api.nvim_set_keymap("n", "<C-G>", "<Cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("t", "<C-G>", "<Cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})

----------------------------
-- BTop++ with toggleterm --
----------------------------

local Terminal  = require('toggleterm.terminal').Terminal
-- local btop = Terminal:new({ cmd = "btop --utf-force", hidden = true, direction = "float" })
-- local btop = Terminal:new({ cmd = "btop", hidden = true, direction = "float" })
local btop = Terminal:new({ cmd = "btm", hidden = true, direction = "float" })
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
vim.api.nvim_set_keymap("n", "<F3>", "<Cmd>lua _fish_toggle()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("t", "<F3>", "<Cmd>lua _fish_toggle()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("v", "<F3>", "<Cmd>lua _fish_toggle()<CR>", {noremap = true, silent = true})

---------------
-- Nvim tree --
---------------

require 'nvim-tree'.setup {
    view = {
        hide_root_folder = true,
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
  -- vert = ' ',
  vert = ' ',
  vertleft  = ' ',
  vertright = ' ',
  verthoriz = ' ',
  eob =' ',
} 

EOF

" ----------
" APPEARANCE
" ----------

" List of available colors in nvim:
"     Red		LightRed	    DarkRed
"     Green	    LightGreen	    DarkGreen	    SeaGreen
"     Blue	    LightBlue	    DarkBlue	    SlateBlue
"     Cyan	    LightCyan	    DarkCyan
"     Magenta	LightMagenta	DarkMagenta
"     Yellow	LightYellow	    Brown		    DarkYellow
"     Gray	    LightGray	    DarkGray
"     Black	    White
"     Orange	Purple		    Violet

" Fish already has a theme, so prevent neovim from adding a theme on top of that.
let $COLORTERM="truecolor"
let $TERM="alacritty"

" Neovide settings.
" let g:neovide_transparency=0.95
let g:neovide_transparency=1
let g:neovide_fullscreen=v:false
let g:neovide_profiler=v:false
let g:neovide_cursor_animation_length = 0.007
" let g:neovide_scroll_animation_length = 0.18
let g:neovide_scroll_animation_length = 0.0
let g:neovide_cursor_antialiasing = v:true

" Fun particles.
" Available options: railgun, torpedo, boom, pixiedust, ripple, wireframe.
let g:neovide_cursor_vfx_mode = "pixiedust"
" Particle settings.
let g:neovide_cursor_vfx_opacity=175.0 " / 256.0
let g:neovide_cursor_vfx_particle_lifetime=0.8
let g:neovide_cursor_vfx_particle_density=5.0
let g:neovide_cursor_vfx_particle_speed=10.0

" Remove the padding in a terminal.
autocmd TermOpen * setlocal signcolumn=no

" Font.  This sets the font for neovide.
" set guifont=JetBrainsMonoMedium\ Nerd\ Font:h10.75
set guifont=JetBrainsMono\ Nerd\ Font:h10.5

" Explicitly enable efm langserver.
let g:lsp_settings = {
\  'efm-langserver': {
\    'disabled': 0,
\   },
\ }

" ----------------
" GENERAL SETTINGS
" ----------------

" Clipboard. 
set clipboard+=unnamedplus 

" Enable mouse input.
set mouse=a

" Syntax.
set number
set relativenumber
set cursorline
set cursorlineopt=both
set hlsearch
set ignorecase
set smartcase

" Disable the cursorline when a window is not focused.
" Keep the number highlight.
augroup CursorLine
    au!
    au VimEnter * setlocal cursorlineopt=both
    au WinEnter * setlocal cursorlineopt=both
    au BufWinEnter * setlocal cursorlineopt=both
    au WinLeave * setlocal cursorlineopt=number
augroup END

" Coc setup.
set pumheight=10 " Limit the height of the seggestion window.

" Setup tabbing.
set tabstop	=4
set softtabstop=4
set shiftwidth =4
set textwidth	=0
set expandtab
set autoindent

" Timeout (for which-key)
set timeoutlen =1000

" Show matching brackets.
set showmatch

" Disable text wrap around.
set nowrap

" Allow FAR to undo.
let g:far#enable_undo=1

" Disable VM exit message and statusline.
let g:VM_set_statusline = 0
let g:VM_silent_exit = 1

" Setup startify.
let g:startify_custom_header =
          \ 'startify#center(startify#fortune#cowsay())'
let g:startify_lists = [
    \ { 'type': 'sessions',  'header': ['   Sessions']       },
    \ { 'type': 'dir',       'header': ['   Local Recents']       },
    \ { 'type': 'files',     'header': ['   Global Recents']         },
\ ]

" ----------
" KEYMAPPING
" ----------

" Barbar.
nnoremap <silent> <C-<> <Cmd>BufferLineMovePrev<CR>
nnoremap <silent> <C->> <Cmd>BufferLineMoveNext<CR>
nnoremap <silent> <C-,> <Cmd>BufferLineCyclePrev<CR>
nnoremap <silent> <C-.> <Cmd>BufferLineCycleNext<CR>
nnoremap <silent> <C-?> <Cmd>lua bdelete<CR>
nnoremap <silent> db <Cmd>BufferLinePickClose<CR>
nnoremap <silent> gb :BufferLinePick<CR>

" File explorer.
nnoremap <silent> <F2> <Cmd>Telescope find_files<CR>
inoremap <silent> <F2> <Cmd>Telescope find_files<CR>
vnoremap <silent> <F2> <Cmd>Telescope find_files<CR>
tnoremap <silent> <F2> <Cmd>Telescope find_files<CR>

" Toggle the file explorer.
nnoremap <silent> <F1> <Cmd>NvimTreeToggle<CR>
inoremap <silent> <F1> <Cmd>NvimTreeToggle<CR>
vnoremap <silent> <F1> <Cmd>NvimTreeToggle<CR>
tnoremap <silent> <F1> <Cmd>NvimTreeToggle<CR>

" Grep for a string in the current directory.
nnoremap <silent> <F4> <Cmd>Telescope live_grep<CR>
inoremap <silent> <F4> <Cmd>Telescope live_grep<CR>
vnoremap <silent> <F4> <Cmd>Telescope live_grep<CR>
tnoremap <silent> <F4> <Cmd>Telescope live_grep<CR>

" Search for old files.
nnoremap <silent> <C-t> <Cmd>Telescope oldfiles<CR>
inoremap <silent> <C-t> <Cmd>Telescope oldfiles<CR>
vnoremap <silent> <C-t> <Cmd>Telescope oldfiles<CR>
tnoremap <silent> <C-t> <Cmd>Telescope oldfiles<CR>

" Cheatsheet.
nnoremap <silent> <F12> <Cmd>Cheatsheet<CR>
inoremap <silent> <F12> <Cmd>Cheatsheet<CR>
vnoremap <silent> <F12> <Cmd>Cheatsheet<CR>
tnoremap <silent> <F12> <Cmd>Cheatsheet<CR>

" Sessions.
nnoremap <silent> <F5> <Cmd>SSave<CR> " <Cmd>lua vim.notify(" Saved current session.", "success", { title = " Session"} )<CR>

" Moving windows.
nnoremap <silent> <C-h> <Cmd>wincmd h<CR>
nnoremap <silent> <C-j> <Cmd>wincmd j<CR>
nnoremap <silent> <C-k> <Cmd>wincmd k<CR>
nnoremap <silent> <C-l> <Cmd>wincmd l<CR>
" Allow moving out of the terminal.
tnoremap <silent> <C-h> <Cmd>wincmd h<CR>
tnoremap <silent> <C-j> <Cmd>wincmd j<CR>
tnoremap <silent> <C-k> <Cmd>wincmd k<CR>
tnoremap <silent> <C-l> <Cmd>wincmd l<CR>

" Ensure we are in normal mode when leaving the terminal.
augroup LeavingTerminal
autocmd! 
autocmd TermLeave <silent> <Esc>
augroup end

" Terminal mappings.
au BufEnter * if &buftype == 'terminal' | :startinsert | endif " Make terminal default mode insert mode.
tnoremap <silent> <Esc> <C-\><C-n>

" Commenting.
nnoremap <silent> <C-/> <Cmd>Commentary<CR>
inoremap <silent> <C-/> <Cmd>Commentary<CR>
vnoremap <silent> <C-/> <Cmd>Commentary<CR>

" Saving.
nnoremap <silent> <C-s> <Cmd>w!<CR>
vnoremap <silent> <C-s> <Cmd>w!<CR>
inoremap <silent> <C-s> <Cmd>w!<CR>

" Buffers.
nnoremap <silent> <C-TAB> <Cmd>Telescope buffers<CR>
inoremap <silent> <C-TAB> <Cmd>Telescope buffers<CR>
tnoremap <silent> <C-TAB> <Cmd>Telescope buffers<CR>
vnoremap <silent> <C-TAB> <Cmd>Telescope buffers<CR>

" Finding.
nnoremap <silent> <C-f> <Cmd>Telescope current_buffer_fuzzy_find previewer=false<CR>
inoremap <silent> <C-f> <Cmd>Telescope current_buffer_fuzzy_find previewer=false<CR>
" Disable the search highlight when hitting esc.
nnoremap <silent> <Esc> <Cmd>noh<CR>
inoremap <silent> <Esc> <Cmd>stopinsert<CR> <Cmd>noh<CR>
vnoremap <silent> <Esc> <Cmd>noh<CR>

" Redo and undo.
nnoremap <silent> <C-Z> <Cmd>undo<CR>
inoremap <silent> <C-Z> <Cmd>undo<CR>
vnoremap <silent> <C-Z> <Cmd>undo<CR>
nnoremap <silent> <C-Y> <Cmd>redo<CR>
inoremap <silent> <C-Y> <Cmd>redo<CR>
vnoremap <silent> <C-Y> <Cmd>redo<CR>

" Zen mode.
nnoremap <silent> <C-a> <Cmd>TZAtaraxis<CR>
vnoremap <silent> <C-a> <Cmd>TZAtaraxis<CR>
inoremap <silent> <C-a> <Cmd>TZAtaraxis<CR>

" Multiline.
" nnoremap <silent> <C-Down> <Down><Cmd>vm-add-cursors<CR>
" nnoremap <silent> <C-Up> <Cmd>vm-add-cursors<CR>

" -------------------------
" RUST PLUGIN CONFIGURARION
" -------------------------

" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

"-----------"
" COC SETUP "
"-----------"

" Extensions.
let g:coc_global_extensions = [
    \ 'coc-clangd',
    \ 'coc-json',
    \ 'coc-julia',
    \ 'coc-pyright',
    \ 'coc-rust-analyzer',
    \ 'coc-lua',
    \ 'coc-git',
\ ]

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  " nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  " nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  " inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  " inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  " vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  " vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
" nmap <silent> <C-s> <Plug>(coc-range-select)
" xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

"-------------------
" COC Notifications.
"-------------------

function! s:DiagnosticNotify() abort
  let l:info = get(b:, 'coc_diagnostic_info', {})
  if empty(l:info) | return '' | endif
  let l:msgs = []
  let l:level = 'info'
   if get(l:info, 'warning', 0)
    let l:level = 'warn'
  endif
  if get(l:info, 'error', 0)
    let l:level = 'error'
  endif
 
  if get(l:info, 'error', 0)
    call add(l:msgs, ' Errors: ' . l:info['error'])
  endif
  if get(l:info, 'warning', 0)
    call add(l:msgs, ' Warnings: ' . l:info['warning'])
  endif
  if get(l:info, 'information', 0)
    call add(l:msgs, ' Infos: ' . l:info['information'])
  endif
  if get(l:info, 'hint', 0)
    call add(l:msgs, ' Hints: ' . l:info['hint'])
  endif
  let l:msg = join(l:msgs, "\n")
  if empty(l:msg) | let l:msg = ' All OK' | endif
  call v:lua.coc_diag_notify(l:msg, l:level)
endfunction

function! s:StatusNotify() abort
  let l:status = get(g:, 'coc_status', '')
  let l:level = 'info'
  if empty(l:status) | return '' | endif
  call v:lua.coc_status_notify(l:status, l:level)
endfunction

function! s:InitCoc() abort
  execute "lua vim.notify('Initialized coc.nvim for LSP support', 'info', { title = 'LSP Status' })"
endfunction

" notifications
" autocmd User CocNvimInit call s:InitCoc()
" autocmd User CocDiagnosticChange call s:DiagnosticNotify()
" autocmd User CocStatusChange call s:StatusNotify()
