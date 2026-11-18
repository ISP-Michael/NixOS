-- Cursor rendering. zoom_factor is the starting value; binds/zoom.lua
-- updates it at runtime with hl.config().
hl.config(
  {
    cursor = {
      no_hardware_cursors = false,
      zoom_rigid = true,
      zoom_factor = 1.0,
    },
  }
)
