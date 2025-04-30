{ pkgs, ... }: with pkgs;
{
  programs = {
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
    fish = {
      enable = true;
      package = fish;
      shellInit = "\n";
    };
  };
}
