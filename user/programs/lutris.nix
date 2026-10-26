{
  pkgs,
  ...
}:
{
  programs = {
    lutris = {
      enable = true;
      extraPackages = with pkgs; [
        vulkan-tools
      ];
      winePackages = [
        pkgs.wineWow64Packages.full
      ];
    };
  };
}
