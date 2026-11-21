{
  pkgs,
  ...
}:
let
  amneziaPackage = pkgs.callPackage ../apps/amnezia/package.nix { };
in
{
  imports = [
    ../apps/amnezia/module.nix
    ../apps/happ/iso-module.nix
  ];

  services.amnezia-vpn = {
    enable = true;
    package = amneziaPackage;
    installToOpt = true;
  };

  # Happ: настоящий Nix-пакет, без ручного /opt. На Hyprland его
  # встроенный Qt-Wayland падает, поэтому принудительно XWayland.
  services.happ = {
    enable = true;
    forceXwayland = true;
  };
}
