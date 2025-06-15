{
  programs.waybar = {
    enable = true;
    settings = {
      verticalBar = {
        width    = 40;
        layer    = "top";
        position = "right";
        output        = [ "eDP-1" ];
        modules-left  = [ "clock" ];
        modules-right = [ "network" "battery" ];
        clock = {
          format  = "{:%H\n%M}";
          tooltip = false;
        };
        battery = {
          format = "{icon}";
          states = {
            warning = 30;
            critical = 15;
          };
          format-icons = [ 
            "󰁺" 
            "󰁻" 
            "󰁼" 
            "󰁽" 
            "󰁾" 
            "󰁿" 
            "󰂀" 
            "󰂁" 
            "󰂂" 
            "󰁹"
          ];
          tooltip = false;
        };
        network = {
          format-wifi         = "󰤨 ";
          format-disconnected = "󰤭 ";
          tooltip             = false;
        };
      };
    };
    style = builtins.readFile ./style.css;
  };
}
