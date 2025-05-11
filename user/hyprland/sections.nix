{
  wayland.windowManager.hyprland.settings = {
    animations.enabled       = true;
    master.new_status        = "master";
    gestures.workspace_swipe = true;
    general = {
      gaps_in               = 5;
      gaps_out              = 5;
      border_size           = 0;
      allow_tearing         = true;
      resize_on_border      = true;
      layout                = "dwindle";
      "col.active_border"   = "rgb(aaa)";
      "col.inactive_border" = "rgb(595959aa)";
    };
    decoration = {
      rounding         = 15;
      active_opacity   = 1;
      inactive_opacity = 1;
      shadow = {
        range        = 20;
        enable       = false;
        render_power = 4;
      };
      blur = {
        size   = 4;
        passes = 3;
        enable = false;
      };
    };
    input = {
      sensitivity  = 0;
      follow_mouse = 1;
      kb_layout    = "us,ru";
      kb_options   = "grp:win_space_toggle";
      touchpad = {
        tap-and-drap   = true;
        natural_scroll = true;
      };
    };
    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo   = true;
    };
    animations = {
      enable = true;
      bezier = [
        "myBezier, 0.05, 0.9 0.1 1.05"
      ];
      animation = [
        "windows,     1,  7, myBezier"
        "windowsOut,  1,  7,  default, popin 80%"
        "border,      1, 10,  default"
        "borderangle, 1,  8,  default"
        "fade,        1,  7,  default"
        "workspaces,  1,  6,  default"
      ];
    };
    dwindle = {
      pseudotile     = true;
      preserve_split = true;
    };
  };
}
