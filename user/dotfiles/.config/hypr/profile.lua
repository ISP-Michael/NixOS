-- Host profile. The live ISO shadows this file with
-- iso/config/hypr/profile.lua, because its entry puts that directory first in
-- package.path. Shared modules only ever see the merged table.
local P = require('lib.defaults')()

P.fileManager = 'dolphin'

-- The wallpaper picker is a local Rust project, not a packaged command.
P.commands.wallpaper = '/home/Michael/Data/Projects/WallpaperPicker/rs/run.sh'

-- CopyQ's settings window sits in the bottom-right corner of the work area,
-- next to the bar.
P.rules.copyq = {
  size = {
    500,
    500,
  },
  move = {
    1366,
    570,
  },
}

-- Dolphin is a file manager, not a tiled editor; keep it floating.
P.rules.dolphin = {
  size = {
    1400,
    800,
  },
}

return P
