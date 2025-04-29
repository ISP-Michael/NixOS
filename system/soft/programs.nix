{ pkgs, ... }: with pkgs;
{
  programs = {
    virt-manager.enable = true;
    steam.enable = true;
    ccache.enable = true;
    firefox = {
      enable = true;
      package = firefox-bin;
    };
    hyprland = {
      enable = true;
      xwayland.enable = true;
      package = hyprland;
      portalPackage = xdg-desktop-portal-hyprland;
    };
    fish = {
      enable = true;
      package = fish;
      shellInit = "\n";
    };
  };
}
