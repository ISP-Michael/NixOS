{ pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";
    autoEnable = true;
    image = ../dependencies/PasterChill.png;
    fonts = {
      sansSerif = {
        name = "Noto Fonts";
        package = pkgs.noto-fonts;
      };
      monospace = {
        name = "Ubuntu Sans Mono";
        package = pkgs.ubuntu-sans-mono;
      };
    };
  };
}

