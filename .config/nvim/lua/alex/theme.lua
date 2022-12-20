------------------------------------
-- Colorscheme and theme settings --
------------------------------------

-- List of available colors in nvim:
-------------------------------------------------------------
--    Red		LightRed	    DarkRed
--    Green	    LightGreen	    DarkGreen	    SeaGreen
--    Blue	    LightBlue	    DarkBlue	    SlateBlue
--    Cyan	    LightCyan	    DarkCyan
--    Magenta	LightMagenta	DarkMagenta
--    Yellow	LightYellow	    Brown		    DarkYellow
--    Gray	    LightGray	    DarkGray
--    Black	    White
--    Orange	Purple		    Violet
-------------------------------------------------------------

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

-- Font.
-- set guifont=JetBrainsMonoMedium\ Nerd\ Font:h10.75
vim.cmd([[set guifont=JetBrainsMono\ Nerd\ Font:h10.5]])
-- vim.cmd('set guifont=FiraCode\ Nerd\ Font:h11.75')
-- vim.cmd('set guifont=FiraCode\ Nerd\ Font:h10.0')

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
vim.g.gruvbox_material_foreground = 'mix'
-- vim.g.gruvbox_material_foreground = 'material'
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
    endfunction
    augroup GruvboxMaterialCustom
        autocmd!
        autocmd ColorScheme gruvbox-material call s:gruvbox_material_custom()
    augroup END
]])

-- Make all buffers that do not have 
-- Apply the colorscheme.
vim.cmd 'colorscheme gruvbox-material'

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

-----------
-- Other --
-----------

vim.g.everforest_background = 'hard'

--------------
-- Material --
--------------

vim.g.material_style = 'darker'
require 'material'.setup {

}
-- vim.cmd 'colorscheme material'
