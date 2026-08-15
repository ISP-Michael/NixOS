{
  lib,
  pkgs,
  ...
}:
{
  # Декларативный юнит для .run-установки AmneziaVPN 5.0.0.5 в /opt/AmneziaVPN.
  # post_install.sh инсталлятора не смог записать юнит сам: /etc/systemd/system
  # на NixOS — read-only симлинк на /etc/static/systemd/system.
  systemd.services.AmneziaVPN = {
    description = "AmneziaVPN Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "1";
      ExecStart = "/opt/AmneziaVPN/bin/AmneziaVPN-service";
      Environment = [
        "NIX_LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib"
      ];
    };
  };

  # Клиент: симлинки, чтобы работал запуск по имени из терминала.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "amnezia-vpn" ''
      exec env NIX_LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib /opt/AmneziaVPN/bin/AmneziaVPN "$@"
    '')
  ];
}
