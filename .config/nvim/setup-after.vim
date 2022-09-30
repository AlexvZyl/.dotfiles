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

" ----------------
" GENERAL SETTINGS
" ----------------

" Redraw status when coc status changes.
autocmd User CocStatusChange redrawstatus

" Do not show the current mode in cmdline.
set noshowmode

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

" Make the cmdline disappear when not in use.
" Currently this is not wokring.
" set cmdheight=0

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
let g:startify_files_number = 15
" TODO!
" let g:startify_custom_footer = [ '***' ]

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
nnoremap <silent> <F3> <Cmd>Telescope find_files<CR>
inoremap <silent> <F3> <Cmd>Telescope find_files<CR>
vnoremap <silent> <F3> <Cmd>Telescope find_files<CR>
tnoremap <silent> <F3> <Cmd>Telescope find_files<CR>

" Toggle the file explorer.
nnoremap <silent> <F2> <Cmd>NvimTreeToggle<CR>
inoremap <silent> <F2> <Cmd>NvimTreeToggle<CR>
vnoremap <silent> <F2> <Cmd>NvimTreeToggle<CR>
tnoremap <silent> <F2> <Cmd>NvimTreeToggle<CR>

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

" Lazygit.
nnoremap <silent> <C-g> <Cmd>LazyGit<CR>
tnoremap <silent> <C-g> <Cmd>LazyGit<CR>
vnoremap <silent> <C-g> <Cmd>LazyGit<CR>
inoremap <silent> <C-g> <Cmd>LazyGit<CR>

" Change lazygit repo.
nnoremap <silent> <C-r> <Cmd>lua require("telescope").extensions.lazygit.lazygit()<CR>
tnoremap <silent> <C-r> <Cmd>lua require("telescope").extensions.lazygit.lazygit()<CR>
vnoremap <silent> <C-r> <Cmd>lua require("telescope").extensions.lazygit.lazygit()<CR>
inoremap <silent> <C-r> <Cmd>lua require("telescope").extensions.lazygit.lazygit()<CR>

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
