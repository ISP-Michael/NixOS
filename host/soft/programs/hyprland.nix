{
  pkgs,
  unstable-pkgs,
  ...
}:
{
  programs = {
    hyprland = {
      enable = true;
      portalPackage = unstable-pkgs.xdg-desktop-portal-hyprland;
      xwayland = {
        enable = true;
      };
    };
  };
}
