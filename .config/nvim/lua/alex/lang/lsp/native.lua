-- Run install-servers.sh to install all the servers used below.

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)

    -- On the Git repo they have a bunch of key bindings here.
    -- I am using Lsp-Saga for LSP info and not the native functions.

end

-- Flags.
local lsp_flags = {
    -- Prevent the LSP client from making too many calls.
    debounce_text_changes = 250,
}

-- Use lspconfig to setup.
local lsp_config = require 'lspconfig'

-- C++.
lsp_config.ccls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    init_options = {
    compilationDatabaseDirectory = "build";
    index = {
      threads = 0;
    };
    clang = {
      excludeArgs = { "-frounding-math"} ;
    };
  }
}

-- Lua.
lsp_config.sumneko_lua.setup {
    on_attach = on_attach,
    flags = lsp_flags
}

-- Julia.
lsp_config.julials.setup {
    on_attach = on_attach,
    flags = lsp_flags
}

-- Bash.
lsp_config.bashls.setup {
    on_attach = on_attach,
    flags = lsp_flags
}

-- Python.
lsp_config.pyright.setup {
    on_attach = on_attach,
    flags = lsp_flags
}

-- Rust.
lsp_config.rust_analyzer.setup {
    on_attach = on_attach,
    flags = lsp_flags
}

-- LaTeX.
lsp_config.texlab.setup {
    on_attach = on_attach,
    flags = lsp_flags,
}

-- CMake.
lsp_config.cmake.setup {
    on_attach = on_attach,
    flags = lsp_flags,
}

-- JSON.
lsp_config.jsonls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
}

-- Diagnostics signs colors and character.
vim.cmd([[
    sign define DiagnosticSignError text= texthl= linehl= numhl=DiagnosticSignError 
    sign define DiagnosticSignWarn  text= texthl= linehl= numhl=DiagnosticSignWarn
    sign define DiagnosticSignInfo  text= texthl= linehl= numhl=DiagnosticSignInfo
    sign define DiagnosticSignHint  text=󱤅 texthl= linehl= numhl=DiagnosticSignHint
]])

local config = {
    virtual_text = false,
    signs = true,
    update_on_insert = true
}
vim.diagnostic.config(config)
