if vim.g.vscode then
    require 'alex.vscode'
    return
end

-- This makes the neovim load faster
vim.loader.enable()

-- Setup environment
local U = require 'alex.utils'
local env_file = os.getenv 'HOME' .. '/.private/nvim_env.lua'
if U.file_exists(env_file) then vim.cmd('luafile ' .. env_file) end

-- Order is important
require 'alex.options'
require 'alex.lazyload'
require 'alex.ui'
require('alex.keymaps').init()
