----------------------
-- General settings --
----------------------

-- Redraw status when coc status changes.
vim.cmd('autocmd User CocStatusChange redrawstatus')

-- Do not show the current mode in cmdline.
vim.cmd('set noshowmode')

-- Clipboard.
vim.cmd('set clipboard+=unnamedplus')

-- Enable mouse input.
vim.cmd('set mouse=a')

-- Syntax.
vim.cmd('set number')
vim.cmd('set relativenumber')
vim.cmd('set cursorline')
vim.cmd('set cursorlineopt=both')
vim.cmd('set hlsearch')
vim.cmd('set ignorecase')
vim.cmd('set smartcase')

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

-- Coc setup.
vim.cmd('set pumheight=10') -- Limit the height of the seggestion window.

-- Setup tabbing.
vim.cmd('set tabstop	=4')
vim.cmd('set softtabstop=4')
vim.cmd('set shiftwidth =4')
vim.cmd('set textwidth	=0')
vim.cmd('set expandtab')
vim.cmd('set autoindent')

-- Timeout (for which-key)
vim.cmd('set timeoutlen =1000')

-- Show matching brackets.
vim.cmd('set showmatch')

-- Disable text wrap around.
vim.cmd('set nowrap')

-- Make the cmdline disappear when not in use.
-- Currently this is not wokring.
-- vim.cmd('set cmdheight=0')

-- Allow FAR to undo.
vim.cmd('let g:far#enable_undo=1')

-- Disable VM exit message and statusline.
vim.g.VM_set_statusline = 0
vim.g.VM_silent_exit = 1

-- Setup startify.
vim.cmd([[
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
]])

-- Ensure we are in normal mode when leaving the terminal.
vim.cmd([[
    augroup LeavingTerminal
    autocmd! 
    autocmd TermLeave <silent> <Esc>
    augroup end
]])

-- Terminal mappings.
vim.cmd([[
    au BufEnter * if &buftype == 'terminal' | :startinsert | endif " Make terminal default mode insert mode.
    tnoremap <silent> <Esc> <C-\><C-n>
]])
