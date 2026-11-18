local startSession = require('lib.session')

hl.on(
  'hyprland.start',
  function()
    startSession()

    -- Scratch terminal; the live config has no host applications.
    hl.exec_cmd(
      'kitty',
      {
        workspace = 'special:magic',
      }
    )
  end
)
