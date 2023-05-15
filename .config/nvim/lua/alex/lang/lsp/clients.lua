-- Run install-servers.sh to install all the servers used below.

local lsp_config = require 'lspconfig'
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lsp_flags = {
    -- Prevent the LSP client from making too many calls.
    debounce_text_changes = 250, -- ms
}

-- Setup LSPs.
lsp_config.ccls.setup {
    flags = lsp_flags,
    init_options = {
        compilationDatabaseDirectory = 'build',
        index = { threads = 0 },
        clang = { excludeArgs = { '-frounding-math' } },
    },
    capabilities = capabilities,
}
lsp_config.lua_ls.setup { flags = lsp_flags, capabilities = capabilities }
lsp_config.julials.setup { flags = lsp_flags, capabilities = capabilities }
lsp_config.bashls.setup { flags = lsp_flags, capabilities = capabilities }
lsp_config.pyright.setup { flags = lsp_flags, capabilities = capabilities }
lsp_config.rust_analyzer.setup { flags = lsp_flags, capabilities = capabilities }
lsp_config.texlab.setup { flags = lsp_flags, capabilities = capabilities }
lsp_config.cmake.setup { flags = lsp_flags, capabilities = capabilities }
lsp_config.jsonls.setup { flags = lsp_flags, capabilities = capabilities }
lsp_config.yamlls.setup { flags = lsp_flags, capabilities = capabilities }
