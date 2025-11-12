let
  icons = [
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
in
{
  programs = {
    waybar = {
      settings = {
        verticalBar = {
          battery = {
            format = "{icon}";
            format-icons = icons;
            tooltip = false;
            states = {
              warning = 30;
              critical = 15;
            };
          };
        };
      };
    };
  };
}
