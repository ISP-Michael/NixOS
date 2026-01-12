{
  services = {
    earlyoom = {
      enable = true;
      freeMemThreshold = 10;
      freeSwapThreshold = 100;
      extraArgs = [
        "-g"
        "--prefer '^(rustc|cc1plus|cmake|ninja)$'"
        "--avoid '^(Hyprland|Xwayland)$'"
      ];
    };
  };
}
