return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim' },
        event = 'VeryLazy',
    },
    {
        'mfussenegger/nvim-dap',
        dependencies = { 'rcarriga/nvim-dap-ui' },
        keys = { 'F1', 'F2' },
        config = function(plugin, _)
            require('alex.lang.debugger.dap').setup_dap(plugin)
            require('alex.lang.debugger.ui').setup_dap_ui(plugin)
        end,
    },
    {
        'glepnir/dashboard-nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        lazy = false,
    },
    { 'NvChad/nvim-colorizer.lua', event = 'VeryLazy' },
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
        keys = { '<leader>d', '<leader>D' },
        event = 'VeryLazy',
    },
    {
        'folke/noice.nvim',
        dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
        event = 'VeryLazy',
    },
    {
        'aserowy/tmux.nvim',
        config = function() return require('tmux').setup() end,
        event = 'VeryLazy',
    },
    { 'lukas-reineke/indent-blankline.nvim', event = 'VeryLazy' },
    { 'RRethy/vim-illuminate', event = 'VeryLazy' },
    { 'preservim/nerdcommenter', event = 'VeryLazy' },
    { 'tpope/vim-commentary', event = 'VeryLazy' },
    {
        'ggandor/leap.nvim',
        dependencies = 'tpope/vim-repeat',
        keys = { 's', 'S' },
    },
    { 'lewis6991/gitsigns.nvim', event = 'VeryLazy' },
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
        build = 'TSUpdate',
        event = 'VeryLazy',
    },
    { 'neovim/nvim-lspconfig', event = 'VeryLazy' },
    { 'glepnir/lspsaga.nvim', event = 'VeryLazy' },
    {
        'L3MON4D3/LuaSnip',
        dependencies = { 'rafamadriz/friendly-snippets' },
        build = 'make install_jsregexp',
        -- This breaks when lazyloading, not sure why...
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
        event = 'VeryLazy',
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
