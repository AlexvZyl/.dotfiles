--------------
-- Nvim Cmp --
--------------

vim.cmd('set completeopt=menu,menuone,noselect')

-- Set up nvim-cmp.
local cmp = require'cmp'

-- Icons.
local kind_icons = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = ""
}

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
          -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        completion = cmp.config.window.bordered {
            winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
        },
        documentation = cmp.config.window.bordered {
            winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
        },
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping( function(fallback)
            if vim.fn.pumvisible() == 1 then
                feedkey("<C-n>", "n")
            elseif cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "i" } ),
        ["<S-Tab>"] = cmp.mapping( function(fallback)
            if vim.fn.pumvisible() == 1 then
                feedkey("<C-p>", "n")
            elseif cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { "i" } ),
    }),
    sources = cmp.config.sources {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'vsnip' }, -- For vsnip users.
        -- { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    },
    formatting = {
        format = function(entry, vim_item)
        local prsnt, lspkind = pcall(require, "lspkind")
            if not prsnt then
	            -- Kind icons
	            vim_item.kind = string.format('%s', kind_icons[vim_item.kind]) -- This concatonates the icons with the name of the item kind
	            return vim_item
	        else
	            return lspkind.cmp_format()
	        end
        end
    }
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

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require('lspconfig')['sumneko_lua'].setup {
  capabilities = capabilities
}
require('lspconfig')['julials'].setup {
  capabilities = capabilities
}
require('lspconfig')['bashls'].setup {
  capabilities = capabilities
}
require('lspconfig')['pyright'].setup {
  capabilities = capabilities
}

-- Disable the scrollbar.
local cmp_window = require('cmp.utils.window')
function cmp_window:has_scrollbar()
  return false
end

-- Limit the height of the seggestion window.
vim.opt.pumheight=10

-- Change the menu border background color.
local palette = require 'alex.utils'.get_gruvbox_material_palette()
vim.cmd('highlight! BorderBG guibg=NONE guifg=' .. palette.grey0[1])
