-- Renderer scheduling. async_commit lets the compositor prepare the next
-- frame without waiting for the previous output commit (new in 0.57).
hl.config(
  {
    render = {
      new_render_scheduling = true,
      async_commit = true,

      -- Direct scanout off: fullscreen Wayland clients (mpv, VMs) showed a
      -- black screen on this GPU. Recheck after Hyprland updates.
      direct_scanout = false,
    },
  }
)
