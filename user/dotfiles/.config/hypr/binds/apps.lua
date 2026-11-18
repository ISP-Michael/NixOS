-- Application launchers. Commands come from profile.lua so the live ISO can
-- use Thunar/kitty without editing shared bindings.
local P = require('profile')

hl.bind(
  P.mainMod .. ' + R',
  hl.dsp.exec_cmd(P.commands.menu)
)

hl.bind(
  P.mainMod .. ' + SHIFT + R',
  hl.dsp.exec_cmd(P.commands.windowMenu)
)

hl.bind(
  P.mainMod .. ' + Q',
  hl.dsp.exec_cmd(P.terminal)
)

hl.bind(
  P.mainMod .. ' + E',
  hl.dsp.exec_cmd(P.fileManager)
)

-- Native Rust wallpaper picker. run.sh opens the window; `close` hides it
-- even if the picker is stuck applying a wallpaper. The command exists only
-- in the host profile.
if P.commands.wallpaper then
  hl.bind(
    P.mainMod .. ' + W',
    hl.dsp.exec_cmd(P.commands.wallpaper)
  )

  hl.bind(
    P.mainMod .. ' + SHIFT + W',
    hl.dsp.exec_cmd(P.commands.wallpaper .. ' close')
  )
end

hl.bind(
  P.mainMod .. ' + P',
  hl.dsp.exec_cmd(P.commands.colorPicker)
)

hl.bind(
  P.mainMod .. ' + B',
  hl.dsp.exec_cmd(P.commands.clipboard)
)
