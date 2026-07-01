{ pkgs, ... }:
{
  stylix = {
    fonts = {
      sansSerif = {
        name = "Noto Fonts";
        package = pkgs.noto-fonts;
      };
      monospace = {
        name = "UbuntuSansMono Nerd Font";
        package = pkgs.ubuntu-sans-mono;
      };
    };
  };
}
