local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_config = require 'lspconfig'
local cmp = require 'cmp'

-- Luasnip.
require('luasnip.loaders.from_vscode').lazy_load()

-- Filter out the text.
local filter_text = function(entry, _)
    local kind = require('cmp.types').lsp.CompletionItemKind[entry:get_kind()]
    return kind ~= 'Text'
end

-- Sources.
cmp.setup {
    sources = cmp.config.sources {
        { name = 'luasnip' },
        { name = 'nvim_lsp', entry_filter = filter_text },
        { name = 'luasnip', entry_filter = filter_text },
        { name = 'buffer', entry_filter = filter_text },
        { name = 'latex_symbols' },
    },
    snippet = {
        expand = function(args) require('luasnip').lsp_expand(args.body) end,
    },
}

-- Seach and help sources.
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' },
    },
})

-- Cmdline completion.
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources {
        { name = 'path' },
        { name = 'cmdline' },
    },
})

-- Setup completion sources with LSPs.
lsp_config.lua_ls.setup { capabilities = capabilities }
lsp_config.julials.setup { capabilities = capabilities }
lsp_config.bashls.setup { capabilities = capabilities }
lsp_config.pyright.setup { capabilities = capabilities }
lsp_config.rust_analyzer.setup { capabilities = capabilities }
lsp_config.texlab.setup { capabilities = capabilities }
