-- The internal panel is 1920x1080. A fixed mode avoids fractional scaling and
-- keeps the geometry in profile.lua and the window rules predictable.
hl.monitor(
  {
    output = 'eDP-1',
    mode = '1920x1080',
    position = '0x0',
    scale = 1,
  }
)
