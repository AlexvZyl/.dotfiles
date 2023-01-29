local function pad_front(section, count)
    for _=1,count do
        table.insert(section, 1, '')
    end
    return section
end

local function pad_end(section, count)
    for _=1,count do
        table.insert(section, '')
    end
    return section
end

local config = {}

config.mru = {}
config.mru.limit = 10

config.project = {}
config.project.limit = 5

config.shortcut = {
    {
        desc = '  New file',
        action = 'enew',
        group = '@string',
        key = 'n'
    },
    {
        desc = '  Update ',
        action = 'PackerSync',
        group = '@string',
        key = 'u'
    },
    {
        desc = '  File/path ',
        action = 'Telescope find_files find_command=rg,--hidden,--files',
        group = '@string',
        key = 'f'
    },
    {
        desc = '  Quit ',
        action = 'q!',
        group = '@macro',
        key = 'q'
    }
}

config.header = {
    '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
    '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
    '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
    '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
    '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
    '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
}

config.footer = {
    'ﯦ  Dala what you must.'
}

-- Default sizes.
local header_height = 6
local center_height = config.mru.limit + config.project.limit + 7
local footer_height = 1

-- Extra padding.
local header_extra_padding = 0
local center_extra_padding = 0
local footer_extra_padding = 0

-- Get window height in rows.
local win_height = vim.api.nvim_win_get_height(0)
local padding = (win_height - header_height - center_height - footer_height) / 4

-- Calculate and set padding for each section.
local header_pad = padding - header_extra_padding
local center_pad = padding - center_extra_padding
local footer_pad = padding - footer_extra_padding

-- Now pad the elements.
config.header = pad_front(config.header, header_pad)
config.header = pad_end(config.header, header_pad)
config.footer = pad_front(config.footer, footer_pad)

-- Setup.
require 'dashboard' .setup {
    theme = 'hyper',
    config = config
}
