-- Run install-servers.sh to install all the servers used below.

-- If specific logic is needed when an LSP attaches to a buffer.
local on_attach = function(client, bufnr) end

local lsp_flags = {
    -- Prevent the LSP client from making too many calls.
    debounce_text_changes = 250, -- ms
}

-- Setup LSPs for difference languages.
local lsp_config = require 'lspconfig'

lsp_config.ccls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    init_options = {
        compilationDatabaseDirectory = 'build',
        index = { threads = 0 },
        clang = { excludeArgs = { '-frounding-math' } },
    },
}
lsp_config.sumneko_lua.setup { on_attach = on_attach, flags = lsp_flags }
lsp_config.julials.setup { on_attach = on_attach, flags = lsp_flags }
lsp_config.bashls.setup { on_attach = on_attach, flags = lsp_flags }
lsp_config.pyright.setup { on_attach = on_attach, flags = lsp_flags }
lsp_config.rust_analyzer.setup { on_attach = on_attach, flags = lsp_flags }
lsp_config.texlab.setup { on_attach = on_attach, flags = lsp_flags }
lsp_config.cmake.setup { on_attach = on_attach, flags = lsp_flags }
lsp_config.jsonls.setup { on_attach = on_attach, flags = lsp_flags }
lsp_config.yamlls.setup { on_attach = on_attach, flags = lsp_flags }
