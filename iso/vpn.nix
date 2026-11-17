{
  pkgs,
  lib,
  ...
}:
let
  amneziaRun = pkgs.callPackage ./amnezia-run.nix { };
in
{
  imports = [
    ../host/services/amnezia-vpn-service.nix
    ../happ-nixos/happ-module.nix
  ];

  # Happ: настоящий Nix-пакет, без ручного /opt. На Hyprland его
  # встроенный Qt-Wayland падает, поэтому принудительно XWayland.
  services.happ = {
    enable = true;
    forceXwayland = true;
  };

  # AmneziaVPN: официальный .run 5.1.0.6 распаковывается в /opt при
  # активации. Сервис/обёртка — из host/services/amnezia-vpn-service.nix.
  system.activationScripts.amneziaInstall = lib.mkBefore ''
    if [ ! -x /opt/AmneziaVPN/bin/AmneziaVPN ]; then
      mkdir -p /opt/AmneziaVPN
      QT_QPA_PLATFORM=offscreen HOME=/root \
        PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin:/usr/bin:/bin \
        ${amneziaRun}/share/amnezia-vpn/AmneziaVPN.run \
        --root /opt/AmneziaVPN \
        --accept-licenses \
        --default-answer \
        --confirm-command install || true
      chmod -R a-w /opt/AmneziaVPN 2>/dev/null || true
    fi
  '';

  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "AmneziaVPN";
      desktopName = "AmneziaVPN";
      exec = "amnezia-vpn";
      icon = "/opt/AmneziaVPN/AmneziaVPN.png";
      comment = "AmneziaVPN client";
      terminal = false;
      categories = [ "Network" ];
    })
  ];

  networking.firewall.trustedInterfaces = [
    "amn0"
  ];
}
