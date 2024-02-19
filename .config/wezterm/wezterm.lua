local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { '/bin/fish' }
config.enable_tab_bar = false

config.max_fps = 75
config.animation_fps = 75

config.window_background_opacity = 0.96

config.font_size = 11.5
config.warn_about_missing_glyphs = false
config.font = wezterm.font({
    family = 'JetBrainsMono Nerd Font',
    weight = 'Medium'
})

config.default_cursor_style = 'BlinkingBlock'

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}


local scheme = wezterm.get_builtin_color_schemes()['Tokyo Night']
--scheme.brights[1] = scheme.ansi[1]
config.color_schemes = { ['Tokyo Night'] = scheme }
config.color_scheme = 'Tokyo Night'


return config
