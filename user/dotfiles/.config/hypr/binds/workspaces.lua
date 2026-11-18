-- Workspaces 1..10 and the special "magic" workspace.
local P = require('profile')

-- Key 10 is `0`; i % 10 maps 10 to 0.
for i = 1, 10 do
  local key = i % 10

  hl.bind(
    P.mainMod .. ' + ' .. key,
    hl.dsp.focus(
      {
        workspace = i,
      }
    )
  )

  hl.bind(
    P.mainMod .. ' + SHIFT + ' .. key,
    hl.dsp.window.move(
      {
        workspace = i,
      }
    )
  )
end

-- "magic" holds the scratch terminal started by autostart.lua.
hl.bind(
  P.mainMod .. ' + S',
  hl.dsp.workspace.toggle_special(
    'magic'
  )
)

hl.bind(
  P.mainMod .. ' + SHIFT + S',
  hl.dsp.window.move(
    {
      workspace = 'special:magic',
    }
  )
)

-- Wheel switches to the next/previous empty workspace (`e+1`/`e-1`).
hl.bind(
  P.mainMod .. ' + mouse_down',
  hl.dsp.focus(
    {
      workspace = 'e+1',
    }
  )
)

hl.bind(
  P.mainMod .. ' + mouse_up',
  hl.dsp.focus(
    {
      workspace = 'e-1',
    }
  )
)
