-----------------
-- Main config --
-----------------

-- These have to be run first and in this order.
require 'alex.packer'
require 'alex.theme'

-- The order of these does not matter.
require 'alex.plugins'
require 'alex.neovide'
require 'alex.general'
require 'alex.lsp'

-- Run this last to ensure they do not get overridden.
require 'alex.keybindings'
