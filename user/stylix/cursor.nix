{ pkgs, ... }:
{
  stylix = {
    cursor = {
      name = "Nordzy-cursors-white";
      package = pkgs.nordzy-cursor-theme;
      size = 36;
    };
  };
}
