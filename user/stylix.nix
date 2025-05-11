{ pkgs, ... }:
{
  stylix = {
    enable     = true;
    autoEnable = false;
    polarity   = "dark";
    image      = ../dependencies/PasterChill.png;

    fonts = with pkgs; {
      sansSerif = {
        name    = "Noto Fonts";
        package = noto-fonts;
      };

      monospace = {
        name    = "Ubuntu Sans Mono";
        package = ubuntu-sans-mono;
      };
    };

    targets = {
      qt.enable  = true;
      gtk.enable = true;
    };
  };
}

