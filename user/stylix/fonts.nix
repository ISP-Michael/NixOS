{
  pkgs,
  ...
}:
{
  stylix = {
    fonts = {
      sansSerif = {
        name = "DejaVu Sans";
        package = pkgs.dejavu_fonts;
      };
      monospace = {
        name = "FiraCode Nerd Font NDD";
        package = pkgs.nerd-fonts.fira-code;
      };
    };
  };
}
