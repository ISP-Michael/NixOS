{
  pkgs,
  ...
}:
{
  stylix = {
    icons = {
      enable = true;
      package = pkgs.nordzy-icon-theme;
      dark = "Nordzy-purple-dark";
      light = "Nordzy-purple-dark";
    };
  };
}
