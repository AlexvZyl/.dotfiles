local u = require 'alex.utils'

-- Bootstrap.
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end
local packer_bootstrap = ensure_packer()

-- UI.
require('packer').init {
    display = { prompt_border = u.border_chars_outer_thin },
}

-- Load different plugins.
return require('packer').startup {
    function(use)
        -- Package manager.
        use 'wbthomason/packer.nvim'

        -- Lua packages.
        use_rocks 'lua-cjson'

        -- Telecope.
        use {
            'nvim-telescope/telescope.nvim',
            requires = {
                'nvim-lua/popup.nvim',
                'nvim-lua/plenary.nvim',
            },
        }

        -- Debugger.
        use {
            'mfussenegger/nvim-dap',
            config = function() require('alex.lang.debugger.dap').setup_dap() end,
        }
        use {
            'rcarriga/nvim-dap-ui',
            config = function() require('alex.lang.debugger.ui').setup_dap_ui() end,
            requires = {
                'mfussenegger/nvim-dap',
            },
        }

        -- General UI.
        --
        use 'NvChad/nvim-colorizer.lua'
        use 'nvim-tree/nvim-web-devicons' -- A bunch of plugins uses this.
        use 'rcarriga/nvim-notify'
        use {
            'nvim-lualine/lualine.nvim',
            requires = {
                'kyazdani42/nvim-web-devicons',
                opt = true,
            },
        }
        use 'glepnir/dashboard-nvim'
        use { 'akinsho/bufferline.nvim', tag = '*', requires = 'nvim-tree/nvim-web-devicons' }
        use {
            'folke/trouble.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
        }
        use {
            'folke/noice.nvim',
            requires = {
                'MunifTanjim/nui.nvim',
                'rcarriga/nvim-notify',
            },
        }
        -- TODO
        use {
            'folke/todo-comments.nvim',
            requires = 'nvim-lua/plenary.nvim',
        }

        -- Tmux.
        use {
            'aserowy/tmux.nvim',
            config = function() return require('tmux').setup() end,
        }

        -- Programming experience.
        use 'lukas-reineke/indent-blankline.nvim'
        use 'RRethy/vim-illuminate'
        use 'windwp/nvim-autopairs'
        use 'preservim/nerdcommenter'
        use 'tpope/vim-commentary'
        use 'brooth/far.vim'
        use {
            'ggandor/leap.nvim',
            requires = 'tpope/vim-repeat',
        }

        -- Git.
        -- TODO
        use 'lewis6991/gitsigns.nvim'
        use 'sindrets/diffview.nvim'
        use 'akinsho/git-conflict.nvim'
        use 'ThePrimeagen/git-worktree.nvim'

        -- Neovim helpers.
        use 'folke/which-key.nvim'
        use 'sudormrfbin/cheatsheet.nvim'

        -- Filesystem.
        use {
            'nvim-tree/nvim-tree.lua',
            requires = {
                'nvim-tree/nvim-web-devicons',
            },
        }

        -- General language.
        use 'mfussenegger/nvim-lint'
        use 'fladson/vim-kitty'
        use {
            'nvim-treesitter/nvim-treesitter',
            requires = {
                'nvim-treesitter/nvim-treesitter-textobjects',
                'nvim-treesitter/playground',
            },
            run = ':TSUpdate',
        }
        use 'neovim/nvim-lspconfig'
        use { 'glepnir/lspsaga.nvim', branch = 'main' }
        use {
            'L3MON4D3/LuaSnip',
            run = 'make install_jsregexp',
            requires = { 'rafamadriz/friendly-snippets' },
        }
        use {
            'hrsh7th/nvim-cmp',
            requires = {
                'hrsh7th/cmp-omni',
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-cmdline',
                'saadparwaiz1/cmp_luasnip',
            },
        }

        -- Language specific.
        use 'lervag/vimtex'

        -- Themes
        use { 'AlexvZyl/nordic.nvim', branch = 'dev' }
        use 'morhetz/gruvbox'
        use 'sainnhe/gruvbox-material'
        use 'EdenEast/nightfox.nvim'
        use 'catppuccin/nvim'
        use 'folke/tokyonight.nvim'
        use 'sainnhe/everforest'
        use 'shaunsingh/nord.nvim'
        use 'rebelot/kanagawa.nvim'
        use 'marko-cerovac/material.nvim'
        use 'Mofiqul/vscode.nvim'
        use 'navarasu/onedark.nvim'
        use 'projekt0n/github-nvim-theme'
        use 'Shatur/neovim-ayu'

        -- Bootstrap.
        if packer_bootstrap then require('packer').sync() end
    end,

    config = {
        display = {
            -- Display packer window as floating.
            open_fn = function() return require('packer.util').float { border = u.border_chars_outer_thin } end,
        },
    },
}
