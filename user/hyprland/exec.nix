{
  wayland.windowManager.hyprland = {
    exec-once = [
      "hyprpaper"
      "clipse -listen"
      "[workspace 1 silent] kitty"
      "[workspace 2 silent] firefox"
      "[workspace 3 silent] telegram-desktop"
    ];
  };
}
