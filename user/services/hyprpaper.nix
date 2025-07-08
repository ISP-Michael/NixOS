{ self, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
        preload   = [        "${self}/dependencies/images/CatpuccinLake.png" ];
        wallpaper = [ "eDP-1, ${self}/dependencies/images/CatpuccinLake.png" ];
      };
  };
}
