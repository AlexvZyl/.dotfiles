vim.loader.enable()

-- Environment.
local u = require 'alex.utils'
local env_file = os.getenv 'HOME' .. '/.private/nvim_env.lua'
if u.file_exists(env_file) then vim.cmd('luafile ' .. env_file) end

-- Order is important.
-- require 'alex.lazy'
require 'alex.packer'
require 'alex.options'
require 'alex.theme'
require 'alex.ui'
require 'alex.lang'
require 'alex.keymaps'
