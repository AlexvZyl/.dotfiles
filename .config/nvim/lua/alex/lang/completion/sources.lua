local cmp = require 'cmp'

-- Load snippets via luasnip.
require('luasnip.loaders.from_vscode').lazy_load()

-- Filter out the text.
local filter_text = function(entry, _)
    local kind = require('cmp.types').lsp.CompletionItemKind[entry:get_kind()]
    return kind ~= 'Text'
end

-- General editing.
local sources = cmp.config.sources({
    { name = 'luasnip' },
    { name = 'nvim_lsp', entry_filter = filter_text },
    { name = 'buffer', entry_filter = filter_text },
})
local snippet = {
    expand = function(args) require('luasnip').lsp_expand(args.body) end,
}
cmp.setup {
    sources = sources,
    snippet = snippet,
}

-- Search.
local search = {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
}
cmp.setup.cmdline({ '/', '?' }, search)

-- Commands.
local commands = {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources {
        { name = 'path' },
        { name = 'cmdline' },
    }
}
cmp.setup.cmdline(':', commands)
