{
  pkgs,
  unstable-pkgs,
  hyprland-pkgs,
  ...
}:
{
  programs = {
    hyprland = {
      enable = true;
      package = unstable-pkgs.hyprland;
      portalPackage = unstable-pkgs.xdg-desktop-portal-hyprland;
      xwayland = {
        enable = true;
      };
    };
  };
}
