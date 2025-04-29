{ pkgs, ... }:
{
  stylix = {
    enable = true;
    image = ../dependencies/PasterChill.png;
    polarity = "dark";
    autoEnable = true;
    fonts = {
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Fonts";
      };
      monospace = {
        package = pkgs.ubuntu-sans-mono;
        name = "Ubuntu Sans Mono";
      };
    };
  };
}

