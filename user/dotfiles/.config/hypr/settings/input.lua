-- Keyboard, touchpad and the drag threshold.
hl.config(
  {
    input = {
      kb_layout = 'us,ru',
      kb_options = 'grp:win_space_toggle',
      follow_mouse = 1,
      sensitivity = 0,
      touchpad = {
        natural_scroll = true,

        -- 0.6 keeps two-finger scrolling smooth without jumping several
        -- screens per gesture.
        scroll_factor = 0.6,

        drag_lock = 0,
        middle_button_emulation = true,
        clickfinger_behavior = true,

        -- Tapping the touchpad counts as a click. Without this, the only way
        -- to click was to press the pad all the way down.
        tap_to_click = true,

        -- Do not scroll the terminal while typing.
        disable_while_typing = true,
      },
    },

    -- Hyprland's `binds` option root (not the keybindings in binds/).
    -- 4 px prevents a normal touchpad click with slight finger movement from
    -- dragging the window.
    binds = {
      drag_threshold = 4,
    },
  }
)
