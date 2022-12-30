------------------------------------
-- Colorscheme and theme settings --
------------------------------------

-- Not too sure why this has to be here.
vim.opt.background = 'dark'

-- Enable colors in the terminal.
if vim.fn.has('termguicolors') then
    vim.cmd('set termguicolors')
end

-- Not too sure why this has to be here?
vim.cmd('let $TERM="alacritty"')

-- Disable the cursorline when a window is not focused.
-- Keep the number highlight.
vim.cmd([[
    augroup CursorLine
        au!
        au VimEnter * setlocal cursorlineopt=both
        au WinEnter * setlocal cursorlineopt=both
        au BufWinEnter * setlocal cursorlineopt=both
        au WinLeave * setlocal cursorlineopt=number
    augroup END
]])

-------------------------
-- Gruvbox (-Material) --
-------------------------

-- Apply custom highlights on colorscheme change.
-- Must be declared before executing ':colorscheme'.
vim.cmd([[
    augroup custom_highlights_gruvboxmaterial
      autocmd!
      autocmd ColorScheme gruvbox-material 
      \ hi TroubleNormal guibg=#141617
    augroup END
]])

-- vim.g.gruvbox_material_foreground = 'original'
-- vim.g.gruvbox_material_foreground = 'mix'
vim.g.gruvbox_material_foreground = 'material'
vim.g.gruvbox_material_background = 'hard'
vim.g.gruvbox_contrast_dark = 'hard'
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_ui_contrast = 'low'
vim.g.gruvbox_material_disable_terminal_colors = 0
vim.g.gruvbox_material_statusline_style = 'default'

-- Custom colors for gruvbox-material.
vim.cmd([[
    function! s:gruvbox_material_custom() abort
        let l:palette = gruvbox_material#get_palette(g:gruvbox_material_background, g:gruvbox_material_foreground, {})
        call gruvbox_material#highlight('CursorLineNr', l:palette.orange, l:palette.none)
        call gruvbox_material#highlight('TabLineSel', l:palette.orange, l:palette.none)
        call gruvbox_material#highlight('TelescopeResultsNormal', l:palette.none, l:palette.bg_dim)
        call gruvbox_material#highlight('TelescopeBorder', l:palette.grey2, l:palette.bg_dim)
        call gruvbox_material#highlight('TelescopeTitle', l:palette.bg_dim, l:palette.orange)
        call gruvbox_material#highlight('TelescopePromptBorder', l:palette.grey2, l:palette.bg1)
        call gruvbox_material#highlight('TelescopePromptNormal', l:palette.none, l:palette.bg1)
        call gruvbox_material#highlight('TelescopeSelection', l:palette.fg1, l:palette.bg1)
        call gruvbox_material#highlight('TelescopeSelectionCaret', l:palette.orange, l:palette.bg_dim)
        call gruvbox_material#highlight('TelescopeMultiSelection', l:palette.orange, l:palette.bg_dim)
        call gruvbox_material#highlight('TelescopePreviewNormal', l:palette.none, l:palette.bg_dim)
        call gruvbox_material#highlight('TelescopePreviewBorder', l:palette.none, l:palette.bg_dim)
        call gruvbox_material#highlight('TelescopePreviewTitle', l:palette.bg_dim, l:palette.blue)
    endfunction
    augroup GruvboxMaterialCustom
        autocmd!
        autocmd ColorScheme gruvbox-material call s:gruvbox_material_custom()
    augroup END
]])

-- Make all buffers that do not have 
-- Apply the colorscheme.
vim.cmd 'colorscheme gruvbox-material'

-- Set custom hl for telescope.

--------------
-- Material --
--------------

require 'material' .setup({

    contrast = {
        terminal = false, -- Enable contrast for the built-in terminal
        sidebars = false, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
        floating_windows = false, -- Enable contrast for floating windows
        cursor_line = false, -- Enable darker background for the cursor line
        non_current_windows = false, -- Enable darker background for non-current windows
        filetypes = {}, -- Specify which filetypes get the contrasted (darker) background
    },

    styles = { -- Give comments style such as bold, italic, underline etc.
        comments = { --[[ italic = true ]] },
        strings = { --[[ bold = true ]] },
        keywords = { --[[ underline = true ]] },
        functions = { --[[ bold = true, undercurl = true ]] },
        variables = {},
        operators = {},
        types = {},
    },

    plugins = { -- Uncomment the plugins that you use to highlight them
        -- Available plugins:
        -- "dap",
        "dashboard",
        "gitsigns",
        -- "hop",
        "indent-blankline",
        "lspsaga",
        -- "mini",
        -- "neogit",
        "nvim-cmp",
        -- "nvim-navic",
        "nvim-tree",
        "nvim-web-devicons",
        -- "sneak",
        "telescope",
        "trouble",
        "which-key",
    },

    disable = {
        colored_cursor = false, -- Disable the colored cursor
        borders = false, -- Disable borders between verticaly split windows
        background = false, -- Prevent the theme from setting the background (NeoVim then uses your terminal background)
        term_colors = false, -- Prevent the theme from setting terminal colors
        eob_lines = false -- Hide the end-of-buffer lines
    },

    high_visibility = {
        lighter = false, -- Enable higher contrast text for lighter style
        darker = false -- Enable higher contrast text for darker style
    },

    lualine_style = "default", -- Lualine style ( can be 'stealth' or 'default' )

    async_loading = true, -- Load parts of the theme asyncronously for faster startup (turned on by default)

    custom_colors = nil, -- If you want to everride the default colors, set this to a function

    custom_highlights = {}, -- Overwrite highlights with your own
})

vim.g.material_style = "darker"
-- vim.cmd 'colorscheme material'

----------
-- Edge --
----------

vim.g.edge_style = 'default'
vim.g.edge_dim_foreground = 0
vim.g.edge_better_performance = 1
-- vim.cmd 'colorscheme edge'

----------------
-- LSP colors --
----------------

-- Tries to set missing LSP colors.
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
-- Everforest --
----------------

vim.g.everforest_background = 'hard'
vim.cmd 'set background =dark'
vim.g.everforest_better_performance = 1
