local plugins = {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim' },
    },
    {
        'mfussenegger/nvim-dap',
        config = function() require('alex.lang.debugger.dap').setup_dap() end,
    },
    {
        'glepnir/dashboard-nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        lazy = false,
    },
    {
        'rcarriga/nvim-dap-ui',
        config = function() require('alex.lang.debugger.ui').setup_dap_ui() end,
        dependencies = { 'mfussenegger/nvim-dap' },
    },
    { 'NvChad/nvim-colorizer.lua' },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    {
        'akinsho/bufferline.nvim',
        version = '*',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    {
        'folke/trouble.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
    },
    {
        'aserowy/tmux.nvim',
        config = function() return require('tmux').setup() end,
    },
    { 'lukas-reineke/indent-blankline.nvim' },
    { 'RRethy/vim-illuminate' },
    { 'preservim/nerdcommenter' },
    { 'tpope/vim-commentary' },
    {
        'ggandor/leap.nvim',
        dependencies = 'tpope/vim-repeat',
    },
    { 'lewis6991/gitsigns.nvim' },
    { 'sindrets/diffview.nvim' },
    { 'folke/which-key.nvim' },
    { 'sudormrfbin/cheatsheet.nvim' },
    {
        'nvim-tree/nvim-tree.lua',
        version = '*',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    { 'mfussenegger/nvim-lint' },
    { 'fladson/vim-kitty' },
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects', 'nvim-treesitter/playground' },
        cmd = 'TSUpdate',
    },
    { 'neovim/nvim-lspconfig' },
    { 'glepnir/lspsaga.nvim' },
    {
        'L3MON4D3/LuaSnip',
        build = 'make install_jsregexp',
        dependencies = { 'rafamadriz/friendly-snippets' },
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-omni',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'saadparwaiz1/cmp_luasnip',
        },
    },
    { 'lervag/vimtex' },

    -- Themes
    { 'AlexvZyl/nordic.nvim', branch = 'dev' },
    { 'sainnhe/gruvbox-material' },
    { 'EdenEast/nightfox.nvim' },
    { 'catppuccin/nvim' },
    { 'folke/tokyonight.nvim' },
    { 'sainnhe/everforest' },
    { 'shaunsingh/nord.nvim' },
    { 'rebelot/kanagawa.nvim' },
    { 'marko-cerovac/material.nvim' },
    { 'Mofiqul/vscode.nvim' },
    { 'navarasu/onedark.nvim' },
    { 'projekt0n/github-nvim-theme' },
    { 'Shatur/neovim-ayu' },
}

local opts = {}

require('lazy').setup(plugins, opts)
