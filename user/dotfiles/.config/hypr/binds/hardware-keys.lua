-- Hardware keys. locked = true keeps them working on the lock screen;
-- repeating = true makes holding the key repeat.
local actions = {
  { key = 'XF86MonBrightnessUp', command = 'brightnessctl s +1%' },
  { key = 'XF86MonBrightnessDown', command = 'brightnessctl s 1%-' },
  { key = 'XF86AudioRaiseVolume', command = 'pamixer -i 5' },
  { key = 'XF86AudioLowerVolume', command = 'pamixer -d 5' },
  { key = 'XF86AudioMute', command = 'pamixer -t' },
}

for _, action in ipairs(actions) do
  hl.bind(
    action.key,
    hl.dsp.exec_cmd(action.command),
    {
      locked = true,
      repeating = true,
    }
  )
end
