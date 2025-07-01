{ pkgs, ... }:
{
  stylix = {
    fonts = {
      sansSerif.name    = "Noto Fonts";
      sansSerif.package = pkgs.noto-fonts;
      monospace.name    = "Ubuntu Sans Mono";
      monospace.package = pkgs.ubuntu-sans-mono;
    };
  };
}
