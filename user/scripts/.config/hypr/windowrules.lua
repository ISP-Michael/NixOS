hl.window_rule(
  {
    name = 'suppress-max',
    match = {
      class = '.*'
    },
    suppress_event = 'maximize',
  }
)

hl.window_rule(
  {
    name = 'media-players',
    match = {
      class = '^(mpv|imv)$'
    },
    fullscreen = false,
  }
)

hl.window_rule(
  {
    name = 'matplotlib-float',
    match = {
      class = '^(Matplotlib)$'
    },
    float = true,
  }
)

hl.window_rule(
  {
    name = 'copyq-settings',
    match = {
      class = '^(com.github.hluk.copyq)$'
    },
    float = true,
    size = {
      500,
      500
    },
    move  = {
      1420,
      578
    },
  }
)

hl.window_rule(
  {
    name = 'dolphin-settings',
    match = {
      class = '^(org.kde.dolphin)$'
    },
    float = true,
    size = {
      1400,
      800
    },
  }
)

hl.window_rule(
  {
    name = 'xdg-portal',
    match = {
      class = '^(xdg-desktop-portal-gtk)$'
    },
    float = true,
  }
)

hl.window_rule(
  {
    name = 'choose-files-telegram',
    match = {
      title = '^(Choose Files)$'
    },
    float = true,
    center = true,
    size = {
      1200,
      800
    },
  }
)

hl.window_rule(
  {
    name = 'choose-files-firefox',
    match = {
      title = '^(Open File - Mozilla Firefox)$'
    },
    float = true,
    center = true,
    size = {
      1200,
      800
    },
  }
)

hl.window_rule(
  {
    name = 'choose-files-vlc',
    match = {
      title = '^(Select one or more files to open)$'
    },
    float = true,
    center = true,
    size = {
      1200,
      800
    },
  }
)

hl.window_rule(
  {
    name = 'choose-login-firefox',
    match = {
      title = '^(Login | Figma — Mozilla Firefox)$'
    },
    float = true,
    center = true,
  }
)

hl.window_rule(
  {
    name = 'blender-file-view',
    match = {
      class = '^(blender)$', title = '^(Blender File View)'
    },
    size = {
      1400,
      800
    },
  }
)

hl.window_rule(
  {
    name  = 'little-window-blueman',
    match = {
      class = '^(.blueman-manager-wrapped)$',
      title = '^(blueman)$'
    },
    float = true,
  }
)

hl.window_rule(
  {
    name = 'telegraph',
    match = {
      title = '^.*(Telegraph)$'
    },
    float = true,
  }
)

hl.window_rule(
  {
    name = 'qbittorrent-under-firefox',
    match = {
      class = 'org.qbittorrent.qBittorrent',
      workspace = '2'
    },
    float = true,
  }
)

hl.window_rule(
  {
    name = 'obs-studio-select',
    match = {
      title = '^(Select what to share)$'
    },
    float = true,
  }
)

hl.layer_rule(
  {
    name = 'screenshot-fade',
    match = {
      namespace = '^selection$'
    },
    animation = 'fade',
  }
)
