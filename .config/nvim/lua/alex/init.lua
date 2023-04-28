local u = require 'alex.utils'

-- Environment.
local env_file = os.getenv 'HOME' .. '/.private/nvim_env.lua'
if u.file_exists(env_file) then vim.cmd('luafile ' .. env_file) end

-- These have to be run first and in this order.
-- require 'alex.lazy'
require 'alex.packer'
require 'alex.theme'

-- Core.
require 'alex.neovim'
require 'alex.neovide'
require 'alex.ui'
require 'alex.lang'

-- Run this last to ensure they do not get overridden.
require 'alex.key-bindings'
