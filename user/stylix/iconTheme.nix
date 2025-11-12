{ pkgs, ... }:
{
  stylix = {
    iconTheme = {
      enable = true;
      package = pkgs.nordzy-icon-theme;
      dark = "Nordzy-purple-dark";
      light = "Nordzy-purple-dark";
    };
  };
}
