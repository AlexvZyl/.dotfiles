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
