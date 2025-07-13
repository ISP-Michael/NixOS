{ pkgs, ... }:
{
  stylix = {
    fonts = {
      sansSerif.name    = "Noto Fonts";
      sansSerif.package = pkgs.noto-fonts;
      monospace.name    = "FiraCodeRoman-Regular";
      monospace.package = pkgs.ubuntu-sans-mono;
    };
  };
}
