{
  unstable-pkgs,
  pkgs,
  ...
}:
{
  xdg = {
    portal = {
      enable = true;
      extraPortals = [
        unstable-pkgs.xdg-desktop-portal-hyprland
        pkgs.kdePackages.xdg-desktop-portal-kde
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
      };
    };
  };
}
