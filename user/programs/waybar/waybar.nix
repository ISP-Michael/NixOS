let
  output        = [ "eDP-1" ];
  modules-left  = [ "clock" ];
  modules-right = [
    "network"
    "battery"
  ];
in
{
  programs = {
    waybar = {
      enable = true;
      settings = {
        verticalBar = {
          width         = 40;
          layer         = "top";
          position      = "right";
          output        = output;
          modules-left  = modules-left;
          modules-right = modules-right;
        };
      };
    };
  };
}
