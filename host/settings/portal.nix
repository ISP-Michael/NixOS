{
  hyprland-pkgs,
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
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
    };
  };
}
