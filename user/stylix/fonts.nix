{ pkgs, ... }:
{
  stylix = {
    fonts = {
      sansSerif = {
        name = "Noto Fonts";
        package = pkgs.noto-fonts;
      };
      monospace = {
        name = "FiraCodeRoman-Regular";
        package = pkgs.ubuntu-sans-mono;
      };
    };
  };
}
