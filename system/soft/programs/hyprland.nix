{ pkgs, ... }:
{
  programs = {
    hyprland = with pkgs; {
      enable          = true;
      xwayland.enable = true;
      package         = hyprland;
      portalPackage   = xdg-desktop-portal-hyprland;
    };
  };
}
