--------------------
-- Plugins config --
--------------------

-- Setup before plugins are loaded.
vim.g.ale_disable_lsp = 1

-- Load different plugins.
return require 'packer'.startup( function(use)

    -- Telecope.
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            'nvim-lua/popup.nvim',
            'nvim-lua/plenary.nvim'
        }
    }

    -- Gui.
    use 'akinsho/toggleterm.nvim'
    use 'rcarriga/nvim-notify'
    use 'nvim-lualine/lualine.nvim'
    use 'kyazdani42/nvim-web-devicons'
    use 'akinsho/bufferline.nvim'
    use 'mhinz/vim-startify'
    use 'b0o/incline.nvim'
    use 'Pocco81/true-zen.nvim' -- Zen mode!
    use 'folke/lsp-colors.nvim'
    -- This only supports native lsp...
    use 'folke/trouble.nvim'

    -- Programming experience.
    use 'lukas-reineke/indent-blankline.nvim'
    use 'mg979/vim-visual-multi'
    use 'karb94/neoscroll.nvim'
    use 'RRethy/vim-illuminate'
    use 'windwp/nvim-autopairs'

    -- Motions.
    use {
        'ggandor/leap.nvim',
        requires = {
            'tpope/vim-repeat'
        }
    }

    -- Git.
    use 'lewis6991/gitsigns.nvim'
    use 'sindrets/diffview.nvim'
    use 'akinsho/git-conflict.nvim'
    use 'kdheepak/lazygit.nvim'
    use {
        'TimUntersberger/neogit',
        requires = {
            'nvim-lua/plenary'
        }
    }

    -- Neovim helpers.
    use 'folke/which-key.nvim'
    use 'sudormrfbin/cheatsheet.nvim'

    -- Filesystem & Searching.
    use 'kyazdani42/nvim-tree.lua'
    use 'BurntSushi/ripgrep'
    use 'brooth/far.vim'

    -- General langage.
    use 'nvim-treesitter/nvim-treesitter'  -- Syntax highlighting.
    use 'preservim/nerdcommenter' -- More commenting functions.
    use 'tpope/vim-commentary'  -- Allow commenting with <C-/>.
    use {
        'neoclide/coc.nvim',
        branch = 'master',
        run = 'yarn install --frozen-lockfile'
    }

    -- Language specific.
    use 'prabirshrestha/vim-lsp'
    use 'JuliaEditorSupport/julia-vim'
    use {
        'autozimu/LanguageClient-neovim',
        branch = 'next',
        cmd = 'bash install.sh'
    }
    use 'sumneko/lua-language-server'
    -- use 'simrat39/rust-tools.nvim'

    -- Themes.
    use 'sainnhe/gruvbox-material' -- My fav.
    use 'catppuccin/nvim' -- This one is nice.
    use 'morhetz/gruvbox'
    use 'folke/tokyonight.nvim'
    use 'EdenEast/nightfox.nvim'
    use 'sainnhe/everforest'
    use 'sainnhe/edge'
    use 'shaunsingh/nord.nvim'
    use 'dracula/vim'
    use 'joshdick/onedark.vim'

    -- Alternative motion usein.
    -- use 'phaazon/hop.nvim'
    -- Still need to setup.
    -- use 'mhartington/formatter.nvim'
    -- For when I make the PR.
    -- use 'Alex-vZyl/toggleterm.nvim', {'tag' : 'v2.*'}
    -- Not yet ready.
    -- use 'petertriho/nvim-scrollbar'
    -- Image viewing.  Not set up currently.
    -- use 'edluffy/hologram.nvim'

end)
