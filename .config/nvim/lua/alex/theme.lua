------------------------------------
-- Colorscheme and theme settings --
------------------------------------

-- List of available colors in nvim:
--    Red		LightRed	    DarkRed
--    Green	    LightGreen	    DarkGreen	    SeaGreen
--    Blue	    LightBlue	    DarkBlue	    SlateBlue
--    Cyan	    LightCyan	    DarkCyan
--    Magenta	LightMagenta	DarkMagenta
--    Yellow	LightYellow	    Brown		    DarkYellow
--    Gray	    LightGray	    DarkGray
--    Black	    White
--    Orange	Purple		    Violet


-- Has to be set before colorscheme is set.
if vim.fn.has('termguicolors') then
    vim.cmd('set termguicolors')
end

-- Apply custom highlights on colorscheme change.
-- Must be declared before executing ':colorscheme'.
vim.cmd([[
    augroup custom_highlights_gruvboxmaterial
      autocmd!
      " floating popups
      autocmd ColorScheme gruvbox-material 
      \       hi NvimTreeNormal      guibg=#141617 |
      \       hi NvimTreeEndOfBuffer guibg=#141617
    augroup END
]])

-- let vim.g.gruvbox_material_foreground = 'original'
-- vim.g.gruvbox_material_foreground = 'mix'
vim.g.gruvbox_material_foreground = 'material'
vim.g.gruvbox_material_background = 'hard'
-- background = 'dark'
vim.g.everforest_background = 'hard'
vim.g.gruvbox_contrast_dark = 'hard'
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_ui_contrast = 'low'
vim.g.gruvbox_material_disable_terminal_colors = 0
vim.g.gruvbox_material_statusline_style = 'default'

-- Custom colors for gruvbox-material.
vim.cmd([[
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
]])

-- Apply the colorscheme.
vim.cmd('colorscheme gruvbox-material')
