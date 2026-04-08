{
  pkgs,
  ...
}:
{
  programs = {
    lutris = {
      enable = false;
      winePackages = [ pkgs.wineWow64Packages.full ];
    };
  };
}
