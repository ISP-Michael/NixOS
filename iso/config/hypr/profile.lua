-- Live ISO profile. The ISO entry puts this directory first in package.path,
-- so shared modules resolve require('profile') to this file and never see the
-- host profile.
local P = require('lib.defaults')()

-- The live image has Thunar instead of Dolphin.
P.fileManager = 'thunar'

-- The host's Rust wallpaper picker is not part of the ISO; binds/apps.lua
-- skips the binding when commands.wallpaper is absent.

-- CopyQ exists only in the work/media/full profiles. Centre it instead of
-- assuming the host's 1920x1080 work area.
P.rules.copyq = {
  size = {
    500,
    500,
  },
  center = true,
}

-- Dolphin appears in the media profile; keep the same floating size as host.
P.rules.dolphin = {
  size = {
    1400,
    800,
  },
}

return P
