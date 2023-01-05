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
            'nvim-lua/plenary.nvim',
            -- Still need to take a look at this guy.
            "nvim-telescope/telescope-live-grep-args.nvim"
        }
    }

    -- Gui.
    use 'akinsho/toggleterm.nvim'
    use 'rcarriga/nvim-notify'
    use {
        'nvim-lualine/lualine.nvim',
        after = 'catppuccin.nvim'
    }
    use 'kyazdani42/nvim-web-devicons'
    use 'akinsho/bufferline.nvim'
    use 'Pocco81/true-zen.nvim'
    use 'glepnir/dashboard-nvim'
    use 'folke/lsp-colors.nvim'
    use {
        'romgrk/barbar.nvim',
        requires = "nvim-tree/nvim-web-devicons",
    }
    use {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
    }
    use { -- This guy still gives some issues.
        "folke/noice.nvim",
        requires = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify"
        }
    }

    -- Images.
    use 'edluffy/hologram.nvim'

    -- Programming experience.
    use 'lukas-reineke/indent-blankline.nvim'
    use 'mg979/vim-visual-multi'
    use 'karb94/neoscroll.nvim'
    use 'RRethy/vim-illuminate'
    use 'windwp/nvim-autopairs'
    use 'preservim/nerdcommenter'
    use 'tpope/vim-commentary'

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
            'nvim-lua/plenary.nvim'
        }
    }
    use 'ThePrimeagen/git-worktree.nvim'

    -- Neovim helpers.
    use 'folke/which-key.nvim'
    use 'sudormrfbin/cheatsheet.nvim'

    -- Filesystem & Searching.
    use 'nvim-tree/nvim-tree.lua'
    use 'BurntSushi/ripgrep'
    use 'brooth/far.vim'

    -- General langage.
    use {
        'nvim-treesitter/nvim-treesitter',
        -- cmd = ":TSUpdate"
    }
    use 'neovim/nvim-lspconfig'
    use {
        "glepnir/lspsaga.nvim",
        branch = "main",
    }

    -- Completion engine.
    use 'L3MON4D3/LuaSnip'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-omni'
        }
    }

    -- Language specific.
    use 'JuliaEditorSupport/julia-vim'
    use 'lervag/vimtex'

    -- Themes.
    use 'sainnhe/gruvbox-material' -- My fav.
    use 'catppuccin/nvim'
    use 'morhetz/gruvbox'
    use 'folke/tokyonight.nvim'
    use 'EdenEast/nightfox.nvim'
    use 'sainnhe/everforest'
    use 'sainnhe/edge'
    use 'shaunsingh/nord.nvim'
    use 'dracula/vim'
    use 'joshdick/onedark.vim'
    use 'sam4llis/nvim-tundra'
    use 'rebelot/kanagawa.nvim'
    use 'cocopon/iceberg.vim'
    use 'marko-cerovac/material.nvim'
    use 'sainnhe/sonokai'
    use {
        'sonph/onehalf',
        rtp = "vim"
    }

    -- Still need to setup.
    -- use 'mhartington/formatter.nvim'
    -- For when I make the PR.
    -- use 'Alex-vZyl/toggleterm.nvim', {'tag' : 'v2.*'}
    -- Not yet ready.
    -- use 'petertriho/nvim-scrollbar'

end)
