{
  pkgs,
  ...
}:
{
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
      ];
      config = {
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
      };
    };
  };
}
