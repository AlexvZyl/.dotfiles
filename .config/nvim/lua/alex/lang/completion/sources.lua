-- Get capabilities.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_config = require 'lspconfig'
local cmp = require 'cmp'

-- Filter out the text.
local filter_text = function(entry, _)
    local kind = require('cmp.types').lsp.CompletionItemKind[entry:get_kind()]
    return kind ~= 'Text'
end

-- Sources.
cmp.setup {
    sources = cmp.config.sources {
        { name = 'nvim_lsp', entry_filter = filter_text },
        { name = 'buffer', entry_filter = filter_text },
        { name = 'luasnip', entry_filter = filter_text },
        { name = 'latex_symbols' },
    },
}

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    }),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' },
    },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' },
    }, {
        { name = 'cmdline' },
    }),
})

cmp.setup.buffer {
    sources = {
        { name = 'nvim_lsp' },
        { name = 'latex_symbols' },
    },
}

-- Setup completion sources with LSPs.
lsp_config.lua_ls.setup {
    capabilities = capabilities,
}
lsp_config.julials.setup {
    capabilities = capabilities,
}
lsp_config.bashls.setup {
    capabilities = capabilities,
}
lsp_config.pyright.setup {
    capabilities = capabilities,
}
lsp_config.rust_analyzer.setup {
    capabilities = capabilities,
}
lsp_config.texlab.setup {
    capabilities = capabilities,
}
