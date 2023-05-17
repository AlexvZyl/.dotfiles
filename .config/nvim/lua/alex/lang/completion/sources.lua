local cmp = require 'cmp'

-- Extensions.
require('luasnip.loaders.from_vscode').lazy_load()

-- Default sources.
local sources = cmp.config.sources {
    { name = 'copilot' },
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
}
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
        { name = 'buffer' },
    },
}
cmp.setup.cmdline({ '/', '?' }, search)

-- Commands.
local commands = {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources {
        { name = 'path' },
        { name = 'cmdline' },
    },
}
cmp.setup.cmdline(':', commands)

-- Latex.
local latex = {
    sources = {
        { name = 'omni' },
        { name = 'latex_symbols' },
        { name = 'buffer' },
    },
}
cmp.setup.filetype({ 'tex' }, latex)
