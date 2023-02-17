--------------
-- Nvim Cmp --
--------------

local cmp = require 'cmp'
local luasnip = require 'luasnip'

vim.cmd('set completeopt=menu,menuone,noselect')

-- Filter out the text.
local function filter_text(entry, _)
    local kind = require('cmp.types').lsp.CompletionItemKind[entry:get_kind()]
    return kind ~= 'Text'
end

-- Icons in the cmp menu.
local kind_icons = {
    Text = " ",
    Method = " ",
    Function = " ",
    Constructor = " ",
    Field = " ",
    Variable = " ",
    Class = "ﴯ ",
    Interface = " ",
    Module = " ",
    Property = "ﰠ ",
    Unit = " ",
    Value = " ",
    Enum = " ",
    Keyword = " ",
    Snippet = " ",
    Color = " ",
    File = " ",
    Reference = " ",
    Folder = " ",
    EnumMember = " ",
    Constant = " ",
    Struct = " ",
    Event = " ",
    Operator = " ",
    TypeParameter = " "
}

-- Used for tabbing in cmp results.
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- Config.
cmp.setup({
    snippet = {
        -- Snippet engine.
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    -- Set window style.
    window = {
        completion = cmp.config.window.bordered {
            winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
            scrollbar = false
        },
        documentation = cmp.config.window.bordered {
            winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
        },
    },
    -- Key maps.
    mapping = cmp.mapping.preset.insert {
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                elseif has_words_before() then
                  cmp.complete()
                else
                  fallback()
                end
            end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
            end, { "i", "s" }),
    },
    sources = cmp.config.sources {
        {
            name = 'nvim_lsp',
            entry_filter = filter_text
        },
        {
            name = 'buffer',
            entry_filter = filter_text
        },
        {
            name = 'luasnip',
            entry_filter = filter_text
        },
        -- For vimtex.
        -- { name = 'omni' },
        { name = 'latex_symbols' },

    },
    formatting = {
        format = function(_, vim_item)
        -- Icons in menu.
        local prsnt, lspkind = pcall(require, "lspkind")
            if not prsnt then
	            vim_item.kind = string.format('%s', kind_icons[vim_item.kind])
	            return vim_item
	        else
	            return lspkind.cmp_format()
	        end
        end
    },
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- Get capabilities.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_config = require 'lspconfig'

-- Setup sources.
lsp_config.lua_ls.setup {
    capabilities = capabilities
}
lsp_config.julials.setup {
    capabilities = capabilities
}
lsp_config.bashls.setup {
    capabilities = capabilities
}
lsp_config.pyright.setup {
    capabilities = capabilities
}
lsp_config.rust_analyzer.setup {
    capabilities = capabilities
}
