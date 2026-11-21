{
  pkgs,
  ...
}:
{
  # Host: Happ 4.7.2+ установлен вручную в /opt/happ (официальный .deb).
  # ISO использует apps/happ/package.nix через iso-module.nix.
  # Обновление — apps/happ/update.sh (backup + restart happd).
  environment.systemPackages = [
    pkgs.net-tools
    pkgs.lsb-release
    (pkgs.writeShellScriptBin "happ" ''
      if [ ! -x /opt/happ/bin/Happ ]; then
        echo "Happ не установлен: нет /opt/happ/bin/Happ" >&2
        exit 1
      fi
      exec /opt/happ/bin/Happ "$@"
    '')
    (pkgs.makeDesktopItem {
      name = "happ";
      desktopName = "Happ";
      exec = "/opt/happ/bin/Happ %f";
      icon = "/opt/happ/happ.png";
      comment = "Happ proxy client (VLESS/VMess/Trojan/Shadowsocks)";
      terminal = false;
      categories = [
        "Utility"
      ];
    })
  ];

  # HWID Happ читает из /var/lib/dbus/machine-id; dbus-broker его не создаёт.
  systemd.tmpfiles.rules = [
    "L+ /var/lib/dbus/machine-id - - - - /etc/machine-id"
  ];

  networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = [
    "tun0"
  ];
  boot.kernelModules = [
    "tun"
  ];

  systemd.services.happd = {
    description = "Happ Process Control Daemon (manual /opt/happ)";
    after = [
      "network.target"
    ];
    wantedBy = [
      "multi-user.target"
    ];
    # Конфиг может собираться на машине без /opt/happ.
    unitConfig = {
      ConditionPathExists = "/opt/happ/bin/happd";
    };
    path = with pkgs; [ iproute2 iptables procps net-tools ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      ExecStart = "/opt/happ/bin/happd";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "10s";
      KillMode = "mixed";
      KillSignal = "SIGTERM";
    };
  };
}
