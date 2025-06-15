{ pkgs, ... }:
{
  stylix = {
    enable     = true;
    autoEnable = false;
    polarity   = "dark";
    image      = ../dependencies/images/CatpuccinLake.png;
    iconTheme = {
      enable  = true;
      package = pkgs.nordzy-icon-theme;
      dark    = "Nordzy-purple-dark";
      light   = "Nordzy-purple-dark";
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
    cursor = {
      name    = "Nordzy-cursors-white";
      package = pkgs.nordzy-cursor-theme;
      size    = 36;
    };
    targets = {
      qt.enable                 = true;
      kde.enable                = true;
      gtk.enable                = true;
      firefox.enable            = true;
      hyprland.enable           = true;
      hyprland.hyprpaper.enable = true;
    };
  };
}
