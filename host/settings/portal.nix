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
        xdg-desktop-portal-termfilechooser
      ];
      config = {
        common = {
          default = [
            "hyprland"
            "termfilechooser"
          ];
        };
      };
    };
  };
}
