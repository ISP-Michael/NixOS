{ pkgs, ... }:
{
  stylix = {
    enable     = true;
    autoEnable = false;
    polarity   = "dark";
    image      = ../dependencies/images/PasterChill.png;
    iconTheme = {
      enable  = true;
      package = pkgs.nordzy-icon-theme;
      dark    = "Nordzy-purple-dark";
    };
    fonts = {
      sansSerif = {
        name    = "Noto Fonts";
        package = pkgs.noto-fonts;
      };
      monospace = {
        name    = "Ubuntu Sans Mono";
        package = pkgs.ubuntu-sans-mono;
      };
    };
    targets = {
      qt.enable                 = true;
      gtk.enable                = true;
      firefox.enable            = true;
      hyprland.enable           = true;
      hyprland.hyprpaper.enable = true;
    };
  };
}

