{ self, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
        preload   = [        "${self}/dependencies/images/pasterChill.png" ];
        wallpaper = [ "eDP-1, ${self}/dependencies/images/pasterChill.png" ];
      };
  };
}
