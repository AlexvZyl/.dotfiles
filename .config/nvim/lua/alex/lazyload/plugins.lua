local plugins = {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim' },
        event = 'VeryLazy',
    },
    {
        'mfussenegger/nvim-dap',
        dependencies = { 'rcarriga/nvim-dap-ui' },
        keys = { 'F1' },
        config = function()
            require('alex.lang.debugger.dap').setup_dap()
            require('alex.lang.debugger.ui').setup_dap_ui()
        end,
    },
    {
        'glepnir/dashboard-nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    { 'NvChad/nvim-colorizer.lua', event = 'VeryLazy' },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        event = 'VeryLazy',
    },
    {
        'akinsho/bufferline.nvim',
        version = '*',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        event = 'VeryLazy',
    },
    {
        'folke/trouble.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        keys = { '<leader>d', '<leader>D' },
    },
    {
        'folke/noice.nvim',
        dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
        event = 'VeryLazy',
    },
    {
        'aserowy/tmux.nvim',
        config = function() return require('tmux').setup() end,
    },
    { 'lukas-reineke/indent-blankline.nvim' },
    { 'RRethy/vim-illuminate', event = 'VeryLazy' },
    { 'preservim/nerdcommenter', event = 'VeryLazy' },
    { 'tpope/vim-commentary', event = 'VeryLazy' },
    {
        'ggandor/leap.nvim',
        dependencies = 'tpope/vim-repeat',
        event = 'VeryLazy',
    },
    { 'lewis6991/gitsigns.nvim' },
    { 'sindrets/diffview.nvim', event = 'VeryLazy' },
    { 'folke/which-key.nvim', event = 'VeryLazy' },
    { 'sudormrfbin/cheatsheet.nvim', event = 'VeryLazy' },
    {
        'nvim-tree/nvim-tree.lua',
        version = '*',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    { 'mfussenegger/nvim-lint', event = 'VeryLazy' },
    { 'fladson/vim-kitty', event = 'VeryLazy' },
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects', 'nvim-treesitter/playground' },
        cmd = 'TSUpdate',
    },
    { 'neovim/nvim-lspconfig' },
    { 'glepnir/lspsaga.nvim' },
    {
        'L3MON4D3/LuaSnip',
        dependencies = { 'rafamadriz/friendly-snippets' },
        build = 'make install_jsregexp',
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
    { 'lervag/vimtex', event = 'VeryLazy' },

    -- Themes
    { 'AlexvZyl/nordic.nvim', branch = 'dev', priority = 1000 },
    { 'sainnhe/gruvbox-material', lazy = true },
    { 'EdenEast/nightfox.nvim', lazy = true },
    { 'catppuccin/nvim', lazy = true },
    { 'folke/tokyonight.nvim', lazy = true },
    { 'sainnhe/everforest', lazy = true },
    { 'shaunsingh/nord.nvim', lazy = true },
    { 'rebelot/kanagawa.nvim', lazy = true },
    { 'marko-cerovac/material.nvim', lazy = true },
    { 'Mofiqul/vscode.nvim', lazy = true },
    { 'navarasu/onedark.nvim', lazy = true },
    { 'projekt0n/github-nvim-theme', lazy = true },
    { 'Shatur/neovim-ayu', lazy = true },
}

local opts = {}

require('lazy').setup(plugins, opts)
