local hyper = true

local config = {}

config.mru = {}
config.mru.limit = 5

config.project = {}
config.project.limit = 10

config.shortcut = {
    {
        desc = '  New file ',
        action = 'enew',
        group = '@string',
        key = 'n',
    },
    {
        desc = '   Update ',
        action = 'PackerSync',
        group = '@string',
        key = 'u',
    },
    {
        desc = '   File/path ',
        action = 'Telescope find_files find_command=rg,--hidden,--files',
        group = '@string',
        key = 'f',
    },
    {
        desc = '   Quit ',
        action = 'q!',
        group = '@macro',
        key = 'q',
    },
}

config.week_header = {}
config.week_header.enable = true
-- config.header = {
-- '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
-- '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
-- '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
-- '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
-- '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
-- '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
-- }

config.footer = {
    '',
    '󰛨  Dala what you must.',
}

config.packages = {}
config.packages.enable = true

-- Default sizes.
local header_height = 10
local center_height = config.mru.limit + config.project.limit + 3
local footer_height = 1

-- Get window height in rows.
local win_height = vim.api.nvim_win_get_height(0)
local padding = (win_height - header_height - center_height - footer_height) / 4

-- Now pad the elements.
config.packages.bottom_padding = 3
config.packages.top_padding = 1
config.header_bottom_padding = 1
config.footer_top_padding = 3

if hyper then
    require('dashboard').setup {
        theme = 'hyper',
        config = config,
    }
    return
end

local custom_center = {
    {
        icon = '  ',
        desc = 'New file      ',
        action = 'enew',
    },
    {
        icon = '  ',
        desc = 'Recent files  ',
        action = 'Telescope oldfiles',
    },
    {
        icon = '  ',
        desc = 'Find file/path',
        action = 'Telescope find_files find_command=rg,--hidden,--files',
    },
    {
        icon = '  ',
        desc = 'Find word     ',
        action = 'Telescope live_grep',
    },
    {
        icon = '  ',
        desc = 'Update plugins',
        action = 'PackerSync',
    },
    {
        icon = '  ',
        desc = 'Quit          ',
        action = 'q!',
    },
}

require('dashboard').setup {
    theme = 'doom',
    config = {
        week_header = {
            enable = true,
        },
        header_bottom_padding = 3,
        footer_top_padding = 3,
        header = config.header,
        center = custom_center,
        footer = config.footer,
    },
}
