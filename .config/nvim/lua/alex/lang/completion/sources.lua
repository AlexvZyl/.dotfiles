local cmp = require 'cmp'

-- Extensions.
require('luasnip.loaders.from_vscode').lazy_load()

-- Default sources.
local sources = cmp.config.sources {
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

-- Tex.
local tex = {
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'latex_symbols' },
    },
}
cmp.setup.filetype({ 'tex', 'latex' }, tex)
