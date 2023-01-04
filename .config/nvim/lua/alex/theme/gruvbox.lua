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

-- Set the colorscheme.
vim.cmd.colorscheme("gruvbox-material")
