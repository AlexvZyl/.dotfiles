lua require 'init'

" Setup nefore plugins are loaded.
let g:ale_disable_lsp = 1

" Has to be set before colorscheme is set.
if has('termguicolors')
    set termguicolors
end

" Enable syntax higjlighting.
syntax on

" Apply custom highlights on colorscheme change.
" Must be declared before executing ':colorscheme'.
augroup custom_highlights_gruvboxmaterial
  autocmd!
  " floating popups
  autocmd ColorScheme gruvbox-material 
  \       hi NvimTreeNormal      guibg=#141617 |
  \       hi NvimTreeEndOfBuffer guibg=#141617
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
" set guifont=FiraCode\ Nerd\ Font:h11.75
" set guifont=FiraCode\ Nerd\ Font:h10.0

" Explicitly enable efm langserver.
let g:lsp_settings = {
\  'efm-langserver': {
\    'disabled': 0,
\   },
\ }
