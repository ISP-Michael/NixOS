{ pkgs, ... }: with pkgs;
{
  programs = {
    fish.enable         = true;
    steam.enable        = true;
    ccache.enable       = true;
    virt-manager.enable = true;
    firefox = {
      enable  = true;
      package = firefox;
    };
    hyprland = {
      enable          = true;
      xwayland.enable = true;
      package         = hyprland;
      portalPackage   = xdg-desktop-portal-hyprland;
    };
  };
}
