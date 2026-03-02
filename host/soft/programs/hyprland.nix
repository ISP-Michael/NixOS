{
  unstable-pkgs,
  hyprland-pkgs,
  ...
}:
{
  programs = {
    hyprland = {
      enable = true;
      package = hyprland-pkgs.hyprland;
      portalPackage = hyprland-pkgs.xdg-desktop-portal-hyprland;
      xwayland = {
        enable = true;
      };
    };
  };
}
