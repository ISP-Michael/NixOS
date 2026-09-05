hl.config(
  {
    general = {
      gaps_in = 0,
      gaps_out = 10,
      border_size = 0,
      col = {
        active_border = 'rgba(102, 102, 102, 0.06)',
        inactive_border = 'rgba(170, 170, 170, 0.02)',
      },
      resize_on_border = true,
      allow_tearing = true,
      layout = 'scrolling',
    },
    decoration = {
      rounding = 0,
      active_opacity = 1.0,
      inactive_opacity = 1.0,
      shadow = {
        enabled = true,
        range = 100,
        render_power = 4,
        color = 0x66000000,
        offset = '0 0',
        scale = 2,
      },
      blur = {
        enabled = false,
        ignore_opacity = true,
        size = 3,
        passes = 4,
        noise = 0.03,
        xray = true,
        contrast = 1.8,
      },
    },
    input = {
      kb_layout = 'us,ru',
      kb_options = 'grp:win_space_toggle',
      follow_mouse = 1,
      sensitivity = 0,
      touchpad = {
        natural_scroll = true,
        drag_lock = 0,
        middle_button_emulation = true,
        clickfinger_behavior = true,
      },
    },
    gestures = {
      workspace_swipe_touch = true,
      workspace_swipe_direction_lock_threshold = 1,
    },
    misc = {
      force_default_wallpaper = 0,
      disable_hyprland_logo = true,
    },
    dwindle = {
      preserve_split = true,
      smart_resizing = false,
    },
    master = {
      new_status = 'master',
      orientation = 'center',
      smart_resizing = false,
    },
    scrolling = {
      column_width = 1.0,
      focus_fit_method = 0,
      follow_focus = true,
      fullscreen_on_one_column = true,
    },
    render = {
      new_render_scheduling = true,
      direct_scanout = true,
    },
    cursor = {
      no_hardware_cursors = false,
      zoom_rigid = true,
      zoom_factor = 1.0,
    },
  }
)
