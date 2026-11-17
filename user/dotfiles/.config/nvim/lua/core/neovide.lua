-- Neovide-only visual and performance settings.
--
-- The app-level settings (font, vsync, idle, box drawing) live in
-- ~/.config/neovide/config.toml; these are runtime variables from
-- https://neovide.dev/configuration.html.
local M = {}

function M.setup()
  -- Opaque window: transparency costs compositing on the Vega 8 and the
  -- flatblack theme is already built around solid backgrounds.
  vim.g.neovide_opacity = 1.0
  vim.g.neovide_normal_opacity = 1.0
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_theme = 'dark'

  -- A little breathing room around the grid. 4 px does not change layout.
  vim.g.neovide_padding_top = 4
  vim.g.neovide_padding_bottom = 4
  vim.g.neovide_padding_left = 4
  vim.g.neovide_padding_right = 4

  -- Keep the window size between launches; let Neovide manage it.
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_hide_mouse_when_typing = true

  -- Snappier than the defaults, but still animated.  The goal is to remove
  -- wasted frames on a 60 Hz panel, not to disable animations completely.
  vim.g.neovide_position_animation_length = 0.10
  vim.g.neovide_scroll_animation_length = 0.20
  vim.g.neovide_scroll_animation_far_lines = 1
  vim.g.neovide_cursor_animation_length = 0.10
  vim.g.neovide_cursor_short_animation_length = 0.03
  vim.g.neovide_cursor_trail_size = 0.8
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_cursor_animate_command_line = false
  vim.g.neovide_cursor_vfx_mode = ''
  vim.g.neovide_cursor_unfocused_outline_width = 0.125

  -- Floating windows: rounded corners and a soft shadow, but no blur.  Skia
  -- blur is the expensive part on this iGPU.
  vim.g.neovide_floating_blur_amount_x = 0.0
  vim.g.neovide_floating_blur_amount_y = 0.0
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 8
  vim.g.neovide_floating_corner_radius = 0.3

  -- Small LSP progress bar; cheap and useful while a language server starts.
  vim.g.neovide_progress_bar_enabled = true
  vim.g.neovide_progress_bar_height = 3.0
  vim.g.neovide_progress_bar_animation_speed = 150.0
  vim.g.neovide_progress_bar_hide_delay = 0.2
end

return M
