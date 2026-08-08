{ pkgs, ... }:
{
  stylix = {
    fonts = {
      sansSerif = {
        name = "Noto Fonts";
        package = pkgs.noto-fonts;
      };
      monospace = {
        name = "FiraCode Nerd Font NDD";
        package = pkgs.nerd-fonts.fira-code;
      };
    };
  };
}
