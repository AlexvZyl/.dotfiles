require 'alex.lazyload.bootstrap'

local U = require 'alex.utils'

local plugins = require 'alex.lazyload.plugins'
local opts = {
    ui = { border = U.border_chars_outer_thin },
    lazy = false,
    checker = { enabled = true },
}
require('lazy').setup(plugins, opts)
