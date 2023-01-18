--------------------
-- Plugins config --
--------------------

-- Setup before plugins are loaded.
vim.g.ale_disable_lsp = 1

-- Load different plugins.
return require 'packer'.startup( { function(use)

    -- Package manager.
    use 'wbthomason/packer.nvim'

    -- Telecope.
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            'nvim-lua/popup.nvim',
            'nvim-lua/plenary.nvim',
        }
    }

    -- Debugger things.
    use 'mfussenegger/nvim-dap'
    use {
        "rcarriga/nvim-dap-ui",
        requires = {
            "mfussenegger/nvim-dap"
        }
    }

    -- UI.
    use 'nvim-tree/nvim-web-devicons'
    use 'j-hui/fidget.nvim'
    use 'akinsho/toggleterm.nvim'
    use 'rcarriga/nvim-notify'
    use {
      'nvim-lualine/lualine.nvim',
      requires = {
          'kyazdani42/nvim-web-devicons',
          opt = true
      }
    }
    use 'glepnir/dashboard-nvim'
    use {
        'romgrk/barbar.nvim',
        requires = "nvim-tree/nvim-web-devicons",
    }
    use {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
    }
    use {
        "folke/noice.nvim",
        requires = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify"
        }
    }
    use {
        "folke/todo-comments.nvim",
        requires = "nvim-lua/plenary.nvim",
    }

    -- Programming experience.
    use 'lukas-reineke/indent-blankline.nvim'
    use 'mg979/vim-visual-multi'
    use 'RRethy/vim-illuminate'
    use 'windwp/nvim-autopairs'
    use 'preservim/nerdcommenter'
    use 'tpope/vim-commentary'
    use 'brooth/far.vim'

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

    -- Filesystem.
    use {
      'nvim-tree/nvim-tree.lua',
      requires = {
        'nvim-tree/nvim-web-devicons'
      },
    }

    -- General langage.
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use 'neovim/nvim-lspconfig'
    use {
        "glepnir/lspsaga.nvim",
        branch = "main",
    }

    -- Language specific.
    use 'JuliaEditorSupport/julia-vim'
    use 'lervag/vimtex'

    -- Completion and snippet engine.
    use {
        'L3MON4D3/LuaSnip',
        requires = {
            'saadparwaiz1/cmp_luasnip'
        }
    }
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-omni',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline'
        }
    }

    -- Fun.
    use 'eandrju/cellular-automaton.nvim'

    -- Themes actually using.
    use 'catppuccin/nvim'
    use 'EdenEast/nightfox.nvim'
    use 'sainnhe/gruvbox-material'

    -- List of nice themes:
    ----------------------------------------
    -- use 'morhetz/gruvbox'
    -- use 'folke/tokyonight.nvim'
    -- use 'sainnhe/everforest'
    -- use 'sainnhe/edge'
    -- use 'shaunsingh/nord.nvim'
    -- use 'dracula/vim'
    -- use 'joshdick/onedark.vim'
    -- use 'sam4llis/nvim-tundra'
    -- use 'rebelot/kanagawa.nvim'
    -- use 'cocopon/iceberg.vim'
    -- use 'marko-cerovac/material.nvim'
    -- use 'sainnhe/sonokai'
    ----------------------------------------

end,

config = {
    display = {
        -- Display packer window as floating.
        open_fn = function ()
            return require 'packer.util'.float { border = 'rounded' }
        end
    }
}

})
