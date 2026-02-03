{
  unstable-pkgs,
  ...
}:
{
  programs = {
    hyprland = {
      enable = true;
      package = unstable-pkgs.hyprland;
      xwayland = {
        enable = true;
      };
    };
  };
}
