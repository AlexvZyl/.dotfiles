require 'alex.lazyload.bootstrap'
require 'alex.lazyload.events'

-- Load plugins
local U = require 'alex.utils'
local plugins = require 'alex.lazyload.plugins'
local opts = {
    ui = { border = U.border_chars_outer_thin },
    defaults = { lazy = false },
    checker = {
        notify = false,
        enabled = true,
    },
}
require('lazy').setup(plugins, opts)
