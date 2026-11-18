-- Hardware keys. locked = true keeps them working on the lock screen;
-- repeating = true makes holding the key repeat.
hl.bind(
  'XF86MonBrightnessUp',
  hl.dsp.exec_cmd(
    'brightnessctl s +1%'
  ),
  {
    locked = true,
    repeating = true,
  }
)

hl.bind(
  'XF86MonBrightnessDown',
  hl.dsp.exec_cmd(
    'brightnessctl s 1%-'
  ),
  {
    locked = true,
    repeating = true,
  }
)

hl.bind(
  'XF86AudioRaiseVolume',
  hl.dsp.exec_cmd(
    'pamixer -i 5'
  ),
  {
    locked = true,
    repeating = true,
  }
)

hl.bind(
  'XF86AudioLowerVolume',
  hl.dsp.exec_cmd(
    'pamixer -d 5'
  ),
  {
    locked = true,
    repeating = true,
  }
)

hl.bind(
  'XF86AudioMute',
  hl.dsp.exec_cmd(
    'pamixer -t'
  ),
  {
    locked = true,
    repeating = true,
  }
)
