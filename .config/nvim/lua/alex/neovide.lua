---------------------------------
-- Settings related to neovide --
---------------------------------

-- vim.g.neovide_transparency=0.75
vim.g.neovide_transparency=1
vim.g.neovide_fullscreen=false
vim.g.neovide_profiler=false
vim.g.neovide_cursor_animation_length = 0.007
-- let vim.g.neovide_scroll_animation_length = 0.18
vim.g.neovide_scroll_animation_length = 0.0
vim.g.neovide_cursor_antialiasing = true

-- Fun particles.
-- Available options: railgun, torpedo, boom, pixiedust, ripple, wireframe.
vim.g.neovide_cursor_vfx_mode = "pixiedust"

-- Particle settings.
vim.g.neovide_cursor_vfx_opacity=175.0 -- / 256.0
vim.g.neovide_cursor_vfx_particle_lifetime=0.8
vim.g.neovide_cursor_vfx_particle_density=5.0
vim.g.neovide_cursor_vfx_particle_speed=10.0

-- Font.
-- vim.opt.guifont = { "JetBrainsMono Nerd Font", ":h10" }
vim.opt.guifont = "JetBrainsMono Nerd Font:h10:#h-full"
-- Outline options: full, normal, slight, none.
-- This seems to remove anooying outlining around some glyphs, but does it make it harder to read?
