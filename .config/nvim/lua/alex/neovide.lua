-- Settings related to neovide.

-- vim.g.neovide_transparency=0.75
vim.g.neovide_transparency=1
vim.g.neovide_fullscreen=false
vim.g.neovide_profiler=false
vim.g.neovide_cursor_animation_length = 0.018
-- vim.g.neovide_scroll_animation_length = 0.8
vim.g.neovide_scroll_animation_length = 0.0
vim.g.neovide_cursor_antialiasing = true

-- Fun particles.
-- Available options: railgun, torpedo, boom, pixiedust, ripple, wireframe.
vim.g.neovide_cursor_vfx_mode = "pixiedust"
vim.g.neovide_cursor_vfx_opacity=175.0 -- / 256.0
vim.g.neovide_cursor_vfx_particle_lifetime=0.8
vim.g.neovide_cursor_vfx_particle_density=5.0
vim.g.neovide_cursor_vfx_particle_speed=10.0

-- Font.
-- Outline options: full, normal, slight, none.
-- This seems to remove anooying outlining around some glyphs, but does it make it harder to read?
-- vim.opt.guifont = { "JetBrainsMono Nerd Font", ":h10" }
vim.opt.guifont = "JetBrainsMono Nerd Font:h10:#h-none"
vim.g.neovide_scale_factor = 1.00
-- For the lols.
-- vim.opt.guifont = "Monocraft Nerd Font:h11.75:#h-none:#e-alias"
