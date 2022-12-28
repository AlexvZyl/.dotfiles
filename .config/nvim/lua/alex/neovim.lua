--------------------
-- Neovim options --
--------------------

-- Do not show the current mode in cmdline.
vim.cmd('set noshowmode')

-- Clipboard.
vim.cmd('set clipboard+=unnamedplus')

-- Enable mouse input.
vim.cmd('set mouse=a')

-- Keep the sign column open.
vim.cmd('set signcolumn=yes')

-- Syntax.
vim.cmd('set number')
vim.cmd('set relativenumber')
vim.cmd('set cursorline')
vim.cmd('set cursorlineopt=both')
vim.cmd('set hlsearch')
vim.cmd('set ignorecase')
vim.cmd('set smartcase')

-- Setup tabbing.
vim.cmd('set tabstop	=4')
vim.cmd('set softtabstop=4')
vim.cmd('set shiftwidth =4')
vim.cmd('set textwidth	=0')
vim.cmd('set expandtab')
vim.cmd('set autoindent')

-- Show matching brackets.
vim.cmd('set showmatch')

-- Disable text wrap around.
vim.cmd('set nowrap')

-- Make the cmdline disappear when not in use.
vim.cmd('set cmdheight=0')

-- Disable VM exit message and statusline.
vim.g.VM_set_statusline = 0
vim.g.VM_silent_exit = 1

-- Neovim fill characters.

--[[ Defaults:
vim.opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft  = '┫',
  vertright = '┣',
  verthoriz = '╋',
}
--]]

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
  eob = ' ',
}

-- Set space as leader.
vim.g.mapleader = ' '

-- Enable winbar.
-- vim.cmd 'set winbar=%f'
-- vim.cmd 'set laststatus=3'

-- Enable spell checking.
vim.cmd ([[
autocmd FileType tex setlocal spell
autocmd FileType tex setlocal spelllang=en
" autocmd BufRead,BufNewFile *.tex setlocal spell
]])

-- Change spell checking hl.
vim.cmd 'hi SpellBad gui=underline'

-- Set wrap for specific file types.
vim.cmd 'autocmd FileType markdown setlocal wrap'
vim.cmd 'autocmd FileType tex setlocal wrap'

-----------------------------
-- Neovim inside Alacritty --
-----------------------------

function Sad(line_nr, from, to, fname)
  vim.cmd(string.format("silent !sed -i '%ss/%s/%s/' %s", line_nr, from, to, fname))
end

function IncreasePadding()
  Sad('07', 0, 20, '~/dotfiles/alacritty/alacritty.windows.yml')
  Sad('08', 0, 20, '~/dotfiles/alacritty/alacritty.windows.yml')
end

function DecreasePadding()
  Sad('07', 20, 0, '~/dotfiles/alacritty/alacritty.windows.yml')
  Sad('08', 20, 0, '~/dotfiles/alacritty/alacritty.windows.yml')
end

-- Remove and add alacritty padding.
-- vim.cmd[[
  -- augroup ChangeAlacrittyPadding
   -- au! 
   -- au VimEnter * lua DecreasePadding()
   -- au VimLeavePre * lua IncreasePadding()
  -- augroup END 
-- ]]
