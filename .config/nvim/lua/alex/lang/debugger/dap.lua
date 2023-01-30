local M = {}

function M.setup_dap()

    local dap = require('dap')

    dap.adapters.cppdbg = {
      id = 'cppdbg',
      type = 'executable',
      command = '/home/alex/.config/nvim/lua/alex/lang/debugger/tools/vscode-cpptools/extension/debugAdapters/bin/OpenDebugAD7',
    }

    local cache = require 'alex.lang.debugger.utils'
    dap.configurations.cpp = {
      {
        name = "Executable",
        type = "cppdbg",
        request = "launch",
        program = function()
            local path = cache.check_exe_cache(vim.fn.getcwd())
            local input = vim.fn.input('Debug: ', path, 'file')
            cache.update_exe_cache(vim.fn.getcwd(), input)
            return input
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = true,
      }
    }

    -- Setup for C and Rust.
    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp

end

return M
