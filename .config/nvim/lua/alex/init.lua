-- Main setup.

-- These have to be run first and in this order.
-- require 'alex.lazy'
require 'alex.packer'
require 'alex.theme'

-- More setup.
require 'alex.neovim'
require 'alex.neovide'
require 'alex.ui'
require 'alex.lang'

-- Run this last to ensure they do not get overridden.
require 'alex.key-bindings'
