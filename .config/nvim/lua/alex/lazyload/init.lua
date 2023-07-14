require 'alex.lazyload.bootstrap'

-- Custom event for lazy loading plugins
vim.api.nvim_create_autocmd('User', {
    callback = function(_) vim.api.nvim_exec_autocmds('User', { pattern = 'NvimStartupDone' }) end,
    pattern = { 'LazyVimStarted' },
    once = true,
})

-- Load plugins
local U = require 'alex.utils'
local plugins = require 'alex.lazyload.plugins'
local opts = {
    ui = { border = U.border_chars_outer_thin },
    defaults = { lazy = false },
    checker = { enabled = true },
}
require('lazy').setup(plugins, opts)
