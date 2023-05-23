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

-- Commands.
local commands = {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources {
        { name = 'path' },
        { name = 'cmdline' },
    },
}
cmp.setup.cmdline(':', commands)

-- Tex.
local tex = {
    sources = {
        { name = 'latex_symbols' },
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
    },
}
cmp.setup.filetype({ 'tex', 'latex' }, tex)
