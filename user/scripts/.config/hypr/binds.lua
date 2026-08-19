---@diagnostic disable: undefined-field
---@module 'variables'
local M = require('variables')

hl.bind(
  M.mainMod .. ' + R',
  hl.dsp.exec_cmd('pkill rofi || rofi -show drun'),
  {
    release = true
  }
)

hl.bind(
  M.mainMod .. ' + Q',
  hl.dsp.exec_cmd(M.terminal)
)

hl.bind(
  M.mainMod .. ' + E',
  hl.dsp.exec_cmd(M.fileManager)
)

hl.bind(
  M.mainMod .. ' + P',
  hl.dsp.exec_cmd('hyprpicker -a')
)

hl.bind(
  M.mainMod .. ' + P',
  hl.dsp.window.pseudo()
)

hl.bind(
  M.mainMod .. ' + C',
  hl.dsp.window.close()
)

hl.bind(
  M.mainMod .. ' + J',
  hl.dsp.layout('togglesplit')
)

hl.bind(
  M.mainMod .. ' + V',
  hl.dsp.window.float(
    {
      action = 'toggle'
    }
  )
)

hl.bind(
  M.mainMod .. ' + B',
  hl.dsp.exec_cmd('copyq toggle')
)

hl.bind(
  'F11',
  hl.dsp.window.fullscreen()
)

hl.bind(
  M.mainMod .. ' + left',
  hl.dsp.focus(
    {
      direction = 'l'
    }
  )
)

hl.bind(
  M.mainMod .. ' + right',
  hl.dsp.focus(
    {
      direction = 'r'
    }
  )
)

hl.bind(
  M.mainMod .. ' + up',
  hl.dsp.focus(
    {
      direction = 'u'
    }
  )
)

hl.bind(
  M.mainMod .. ' + down',
  hl.dsp.focus(
    {
      direction = 'd'
    }
  )
)

for i = 1, 10 do
  local key = i % 10
  hl.bind(
    M.mainMod .. ' + ' .. key,
    hl.dsp.focus(
      {
        workspace = i
      }
    )
  )
  hl.bind(
    M.mainMod .. ' + SHIFT + ' .. key,
    hl.dsp.window.move(
      {
        workspace = i
      }
    )
  )
end

hl.bind(
  M.alt .. ' + Tab',
  hl.dsp.window.bring_to_top()
)

hl.bind(
  M.alt .. ' + SHIFT + Tab',
  hl.dsp.window.bring_to_top(
    {
      prev = true
    }
  )
)

hl.bind(
  M.mainMod .. ' + S',
  hl.dsp.workspace.toggle_special(
    'magic'
  )
)

hl.bind(
  M.mainMod .. ' + SHIFT + S',
  hl.dsp.window.move(
    {
      workspace = 'special:magic'
    }
  )
)

hl.bind(
  M.mainMod .. ' + mouse_down',
  hl.dsp.focus(
    {
      workspace = 'e+1'
    }
  )
)

hl.bind(
  M.mainMod .. ' + mouse_up',
  hl.dsp.focus(
    {
      workspace = 'e-1'
    }
  )
)

hl.bind(
  M.mainMod .. ' + period',
  hl.dsp.layout(
    'move +col'
  )
)

hl.bind(
  M.mainMod .. ' + comma',
  hl.dsp.layout(
    'move -col'
  )
)

hl.bind(
  'XF86MonBrightnessUp',
  hl.dsp.exec_cmd(
    'brightnessctl s +1%'
  ),
  {
    locked = true,
    repeating = true
  }
)

hl.bind(
  'XF86MonBrightnessDown',
  hl.dsp.exec_cmd(
    'brightnessctl s 1%-'
  ),
  {
    locked = true,
    repeating = true
  }
)

hl.bind(
  'XF86AudioRaiseVolume',
  hl.dsp.exec_cmd(
    'pamixer -i 5'
  ),
  {
    locked = true,
    repeating = true
  }
)

hl.bind(
  'XF86AudioLowerVolume',
  hl.dsp.exec_cmd(
    'pamixer -d 5'
  ),
  {
    locked = true,
    repeating = true
  }
)

hl.bind(
  'XF86AudioMute',
  hl.dsp.exec_cmd(
    'pamixer -t'
  ),
  {
    locked = true,
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + mouse:272',
  hl.dsp.window.drag(),
  {
    mouse = true
  }
)

hl.bind(
  M.mainMod .. ' + mouse:273',
  hl.dsp.window.resize(),
  {
    mouse = true
  }
)

hl.bind(
  M.mainMod .. ' + SHIFT + h',
  hl.dsp.window.resize(
    {
      x = -20,
      y = 0,
      relative = true
    }
  ),
  {
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + SHIFT + l',
  hl.dsp.window.resize(
    {
      x = 20,
      y = 0,
      relative = true
    }
  ),
  {
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + SHIFT + k',
  hl.dsp.window.resize(
    {
      x = 0,
      y = -20,
      relative = true
    }
  ),
  {
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + SHIFT + j',
  hl.dsp.window.resize(
    {
      x = 0,
      y = 20,
      relative = true
    }
  ),
  {
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + G',
  hl.dsp.group.toggle()
)

hl.bind(
  M.mainMod .. ' + CTRL + G',
  hl.dsp.window.move(
    {
      into_group = 'l'
    }
  )
)

hl.bind(
  M.mainMod .. ' + ALT + G',
  hl.dsp.window.move(
    {
      out_of_group = true
    }
  )
)

hl.bind(
  M.mainMod .. ' + SHIFT + P',
  hl.dsp.exec_cmd(
    '/etc/nixos/dependencies/scripts/obs_screenshot.sh'
  )
)

hl.bind(
  M.mainMod .. ' + equal',
  hl.dsp.exec_cmd(
    'hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq \'.float + 1\')'
  ),
  {
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + minus',
  hl.dsp.exec_cmd(
    'hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq \'.float - 1\')'
  ),
  {
    repeating = true
  }
)
