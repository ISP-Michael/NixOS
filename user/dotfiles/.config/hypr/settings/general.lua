-- General layout and window behavior.
hl.config(
  {
    general = {
      gaps_in = 0,
      gaps_out = 10,
      border_size = 0,
      col = {
        active_border = 'rgba(102, 102, 102, 0.06)',
        inactive_border = 'rgba(170, 170, 170, 0.02)',
      },
      resize_on_border = true,

      -- Games may request tearing; normal clients still get vsync.
      allow_tearing = true,

      -- Monocle: one window fills the screen, SUPER+arrows/comma/period
      -- cycle. Scrolling was removed: at column_width = 1.0 and
      -- fullscreen_on_one_column it behaved the same but paid for strip
      -- geometry and slide animation.
      layout = 'monocle',
    },
  }
)
