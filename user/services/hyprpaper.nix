{ self, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
        preload = [ "${self}/dependencies/images/siber_true.png" ];
        wallpaper = [ "eDP-1, ${self}/dependencies/images/siber_true.png" ];
      };
  };
}
