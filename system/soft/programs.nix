{ pkgs, ... }: with pkgs;
{
  programs = {
    fish.enable = true;
    steam.enable = true;
    ccache.enable = true;
    virt-manager.enable = true;
    firefox = {
      enable = true;
      package = firefox-bin;
    };
    hyprland = {
      enable = true;
      package = hyprland;
      xwayland.enable = true;
      portalPackage = xdg-desktop-portal-hyprland;
    };
  };
}
