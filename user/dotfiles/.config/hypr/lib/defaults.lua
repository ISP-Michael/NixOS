-- Shared defaults for the host and the live ISO. Returns a fresh table so a
-- profile can add or override values without mutating the defaults. Modules
-- read the merged table via require('profile').
return function()
  return {
    mainMod = 'SUPER',
    alt = 'ALT',
    ctrl = 'CTRL',

    terminal = 'kitty',
    fileManager = 'dolphin',

    -- Cursor zoom stops. The active index is kept by binds/zoom.lua.
    zoomSteps = { 1.0, 1.25, 1.5, 2.0, 2.5, 3.0 },

    commands = {
      menu = 'rofi -show drun',
      windowMenu = 'rofi -show window',
      clipboard = 'copyq toggle',
      colorPicker = 'hyprpicker -a',
    },

    dialogs = {
      width = 1200,
      height = 800,
    },

    -- Per-app window geometry. profile.lua adds or overrides entries.
    rules = {},
  }
end
