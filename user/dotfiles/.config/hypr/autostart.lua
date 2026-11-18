local P = require('profile')
local startSession = require('lib.session')

hl.on(
  'hyprland.start',
  function()
    startSession()

    -- Background services.
    hl.exec_cmd('copyq')
    if P.commands.wallpaper then
      hl.exec_cmd(P.commands.wallpaper .. ' daemon')
    end
    hl.exec_cmd('openclaw gateway run')

    -- Applications start on silent workspaces so login does not steal focus.
    hl.exec_cmd('zen', { workspace = '2 silent' })
    hl.exec_cmd('Telegram', { workspace = '3 silent' })
    hl.exec_cmd('obsidian', { workspace = '4 silent' })
    hl.exec_cmd('lutris', { workspace = '5 silent' })
    hl.exec_cmd('Throne', { workspace = '9 silent' })
    hl.exec_cmd('amnezia-vpn', { workspace = '9 silent' })
    hl.exec_cmd('kitty', { workspace = 'special:magic silent' })
  end
)
