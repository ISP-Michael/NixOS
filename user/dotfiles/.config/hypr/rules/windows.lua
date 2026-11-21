-- Window rules. Match properties are ANDed: each field in `match` must match.
-- String matches are RE2::FullMatch over the whole string.
local P = require('profile')

-- F11 fullscreen is a different event and is not affected.
hl.window_rule(
  {
    name = 'suppress-maximize',
    match = {
      class = '.*',
    },
    suppress_event = 'maximize',
  }
)

-- mpv/imv should not open fullscreen; F11 still works.
hl.window_rule(
  {
    name = 'media-players',
    match = {
      class = '^(mpv|imv)$',
    },
    fullscreen = false,
  }
)

-- Tk under X11 reports class Matplotlib with a capital M.
hl.window_rule(
  {
    name = 'matplotlib-float',
    match = {
      class = '^(Matplotlib)$',
    },
    float = true,
  }
)

-- CopyQ's only window is its settings dialog. Geometry comes from profile.lua
-- because the host and the live ISO have different work areas.
if P.rules.copyq then
  hl.window_rule(
    {
      name = 'copyq-settings',
      match = {
        class = '^(com.github.hluk.copyq)$',
      },
      float = true,
      size = P.rules.copyq.size,
      move = P.rules.copyq.move,
      center = P.rules.copyq.center,
    }
  )
end

-- Dolphin is a file manager; keep it floating instead of filling the screen.
if P.rules.dolphin then
  hl.window_rule(
    {
      name = 'dolphin-floating',
      match = {
        class = '^(org.kde.dolphin)$',
      },
      float = true,
      size = P.rules.dolphin.size,
    }
  )
end

-- Figma login popup in Firefox. The pipe is literal, hence the escape.
hl.window_rule(
  {
    name = 'figma-login',
    match = {
      title = '^(Login \\| Figma — Mozilla Firefox)$',
    },
    float = true,
    center = true,
  }
)

-- OBS window-capture picker, not a file dialog.
hl.window_rule(
  {
    name = 'obs-share-picker',
    match = {
      title = '^(Select what to share)$',
    },
    float = true,
  }
)

-- Gamepad input goes straight to the game (SDL/evdev) and never reaches the
-- compositor's seat, so Hyprland/Noctalia see no activity and lock the screen
-- mid-game. Inhibit idle while a game window exists.
hl.window_rule(
  {
    name = 'games-idle-inhibit',
    match = {
      class = '^(steam_app_default|gamescope)$',
    },
    idle_inhibit = 'always',
  }
)

-- Silksong: keep the game window floating so its own resolution setting
-- (Screen.SetResolution) is honored instead of being tiled to the work area.
hl.window_rule(
  {
    name = 'silksong-floating',
    match = {
      class = '^steam_app_default$',
      title = '.*Silksong.*',
    },
    float = true,
  }
)
