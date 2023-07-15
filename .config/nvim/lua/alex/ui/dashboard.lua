local config = {}

config.mru = { limit = 10 }
config.project = { limit = 10 }

config.shortcut = {
    {
        desc = '  New file ',
        action = 'enew',
        group = '@string',
        key = 'n',
    },
    {
        desc = '   File/path ',
        action = 'Telescope find_files find_command=rg,--hidden,--files',
        group = '@string',
        key = 'f',
    },
    {
        desc = '   Update ',
        action = 'Lazy sync',
        group = '@string',
        key = 'u',
    },
    {
        desc = '   Mason ',
        action = 'Mason',
        group = '@string',
        key = 'm',
    },
    {
        desc = ' 󰓅  Profile ',
        action = 'Lazy profile',
        group = '@string',
        key = 'p',
    },
    {
        desc = '   Quit ',
        action = 'q!',
        group = '@macro',
        key = 'q',
    },
}

config.week_header = { enable = true }
config.footer = { '', '󰛨  Dala what you must' }
config.packages = { enable = true }

require('dashboard').setup {
    theme = 'hyper',
    config = config,
}
