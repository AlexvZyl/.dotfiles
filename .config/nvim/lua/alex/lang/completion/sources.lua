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
        -- { name = 'cmp_tabnine' },
        { name = 'nvim_lsp', entry_filter = filter_text },
        { name = 'luasnip', entry_filter = filter_text },
        { name = 'buffer', entry_filter = filter_text },
        { name = 'latex_symbols' },
    },
}

local tabnine = require 'cmp_tabnine.config'
tabnine:setup {
    max_lines = 50,
    max_num_results = 1,
    sort = true,
    run_on_every_keystroke = true,
    snippet_placeholder = '..',
    ignored_file_types = {
        -- default is not to ignore
        -- uncomment to ignore in lua:
        -- lua = true
    },
    show_prediction_strength = false,
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

-- Tabnine baby.
--[[
require('tabnine').setup {
    disable_auto_comment=true,
    accept_keymap="<Tab>",
    dismiss_keymap = "<C-]>",
    debounce_ms = 800,
    suggestion_color = {gui = "#808080", cterm = 244},
    exclude_filetypes = {"TelescopePrompt"},
    log_file_path = nil, -- absolute path to Tabnine log file
}
--]]
