-- Cursor zoom. The index lives in this module; each keypress writes
-- cursor.zoom_factor directly with hl.config(), without spawning hyprctl.
local P = require('profile')

local zoomIndex = 1

local function zoom(step)
  zoomIndex = math.min(#P.zoomSteps, math.max(1, zoomIndex + step))
  hl.config(
    {
      cursor = {
        zoom_factor = P.zoomSteps[zoomIndex],
      },
    }
  )
end

hl.bind(P.mainMod .. ' + equal', function() zoom(1) end)
hl.bind(P.mainMod .. ' + minus', function() zoom(-1) end)
