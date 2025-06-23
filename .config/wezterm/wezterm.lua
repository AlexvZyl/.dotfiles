local wezterm = require 'wezterm'

local config = {}

config.default_prog = { 'fish' }
config.enable_tab_bar = false

config.max_fps = 100
config.animation_fps = 100

-- config.window_background_opacity = 0.94
config.window_background_opacity = 1
config.use_resize_increments = true

config.font_size = 13
config.underline_thickness = 1
config.underline_position = -5.0
-- config.freetype_load_target = "Normal"
config.bold_brightens_ansi_colors = false
-- config.freetype_render_target = 'Normal'
-- config.freetype_load_flags = 'NO_HINTING'

config.audible_bell = "Disabled"
config.warn_about_missing_glyphs = false
config.font = wezterm.font({
    family = 'JetBrains Mono',
    weight = 'Medium'
})

config.default_cursor_style = 'BlinkingBlock'

config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

-- Neovim colors.
config.colors = {
    foreground = "#E0E2EA",
    background = "#14161B",
    ansi = {
        '#07080D',
        '#F08080',
        '#B3F6C0',
        '#FCE094',
        '#87CEFA',
        '#ffcaff',
        "#8cf8f7",
        '#eef1f8',
    },
    brights = {
        '#4F5258',
        '#F08080',
        '#B3F6C0',
        '#FCE094',
        '#87CEFA',
        '#ffcaff',
        "#8cf8f7",
        '#eef1f8',
    },
}
config.colors.cursor_bg = config.colors.foreground
config.colors.cursor_border = config.colors.foreground
config.colors.split = config.colors.foreground

config.anti_alias_custom_block_glyphs = true
config.custom_block_glyphs = true

local gpus = wezterm.gui.enumerate_gpus()
config.webgpu_preferred_adapter = gpus[1]
config.front_end = 'OpenGL'

return config
