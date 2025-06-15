{
  config,
  ...
}:
{
  services.hyprpaper = {
    enable = true;
    settings =
      let
        wallpaper = config.stylix.image;
      in
      {
        preload   = [ "${wallpaper}" ];
        wallpaper = [ "eDP-1, ${wallpaper}" ];
      };
  };
}
