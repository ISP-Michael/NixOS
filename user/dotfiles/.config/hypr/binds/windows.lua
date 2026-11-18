-- Window management and monocle navigation.
local P = require('profile')

hl.bind(
  P.mainMod .. ' + C',
  hl.dsp.window.close()
)

-- Monocle implements only cyclenext/cycleprev. Arrow keys cannot move focus
-- between windows: moveTargetInDirection() only looks for another monitor,
-- and this laptop has one (eDP-1). So arrows and comma/period all cycle.
local function cycle(step)
  hl.dispatch(hl.dsp.layout(step > 0 and 'cyclenext' or 'cycleprev'))
end

hl.bind(P.mainMod .. ' + right', function() cycle(1) end)
hl.bind(P.mainMod .. ' + left', function() cycle(-1) end)
hl.bind(P.mainMod .. ' + down', function() cycle(1) end)
hl.bind(P.mainMod .. ' + up', function() cycle(-1) end)
hl.bind(P.mainMod .. ' + comma', function() cycle(1) end)
hl.bind(P.mainMod .. ' + period', function() cycle(-1) end)

-- Alt+Tab is a window switcher, not a z-order change (monocle shows one
-- window anyway).
hl.bind(P.alt .. ' + Tab', function() cycle(1) end)
hl.bind(P.alt .. ' + SHIFT + Tab', function() cycle(-1) end)

hl.bind(
  P.mainMod .. ' + V',
  hl.dsp.window.float(
    {
      action = 'toggle',
    }
  )
)

hl.bind(
  'F11',
  hl.dsp.window.fullscreen()
)

hl.bind(
  P.mainMod .. ' + SHIFT + V',
  hl.dsp.window.pseudo()
)

-- Groups.
hl.bind(
  P.mainMod .. ' + G',
  hl.dsp.group.toggle()
)

hl.bind(
  P.mainMod .. ' + ' .. P.ctrl .. ' + G',
  hl.dsp.window.move(
    {
      into_group = 'l',
    }
  )
)

hl.bind(
  P.mainMod .. ' + ' .. P.alt .. ' + G',
  hl.dsp.window.move(
    {
      out_of_group = true,
    }
  )
)

-- Keyboard resize works only on floating windows: monocle overwrites a tiled
-- window's size on every relayout.
local resizeStep = 20
local resizeKeys = {
  { 'h', -resizeStep, 0 },
  { 'l', resizeStep, 0 },
  { 'k', 0, -resizeStep },
  { 'j', 0, resizeStep },
}

for _, resize in ipairs(resizeKeys) do
  hl.bind(
    P.mainMod .. ' + SHIFT + ' .. resize[1],
    hl.dsp.window.resize(
      {
        x = resize[2],
        y = resize[3],
        relative = true,
      }
    ),
    {
      repeating = true,
    }
  )
end

-- Mouse drag/resize.
hl.bind(
  P.mainMod .. ' + mouse:272',
  hl.dsp.window.drag(),
  {
    mouse = true,
  }
)

hl.bind(
  P.mainMod .. ' + mouse:273',
  hl.dsp.window.resize(),
  {
    mouse = true,
  }
)
