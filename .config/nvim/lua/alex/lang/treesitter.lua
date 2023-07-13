require('nvim-treesitter.configs').setup {

    ensure_installed = {
        'c',
        'cpp',
        'lua',
        'rust',
        'julia',
        'python',
        -- 'yaml',
        'vim',
        'json',
        'regex',
        -- 'bash',
        'markdown',
        'markdown_inline',
        'yaml',
        'kdl',
        'latex',
    },

    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true,
        disable = { 'latex', 'tex' },
        additional_vim_regex_highlighting = false,
    },

    indent = { enable = true },

    textobjects = {
        select = { enable = true },
        move = {
            enable = true,
            goto_next_start = {
                [']f'] = '@function.outer',
                [']c'] = '@class.outer',
            },
            goto_previous_start = {
                ['[f'] = '@function.outer',
                ['[c'] = '@class.outer',
            },
            goto_next_end = {
                [']F'] = '@function.outer',
                [']C'] = '@class.outer',
            },
            goto_previous_end = {
                ['[F'] = '@function.outer',
                ['[C'] = '@class.outer',
            },
        },
    },

    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
    },
}
