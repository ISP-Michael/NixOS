-- Background, logo and DPMS behavior.
hl.config(
  {
    misc = {
      force_default_wallpaper = 0,
      disable_hyprland_logo = true,

      -- Opaque black instead of the default grey. 0x000000 would be parsed
      -- as fully transparent.
      background_color = 0xFF000000,

      -- Moving the mouse wakes the panel; otherwise only the power button did.
      mouse_move_enables_dpms = true,
    },
  }
)
