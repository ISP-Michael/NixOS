{ pkgs, ... }:
{
  # Happ 4.7.2 установлен вручную в /opt/happ (официальный .deb, repack).
  # Модуль happ-nixos больше не импортируется: NixOS не управляет /opt/happ и не
  # перезаписывает его при activation/reboot. Обновление — заменить /opt/happ
  # и `sudo systemctl restart happd`.
  environment.systemPackages = [
    pkgs.net-tools
    pkgs.lsb-release
    (pkgs.writeShellScriptBin "happ" ''
      exec /opt/happ/bin/Happ "$@"
    '')
    (pkgs.makeDesktopItem {
      name = "happ";
      desktopName = "Happ";
      exec = "/opt/happ/bin/Happ %f";
      icon = "/opt/happ/happ.png";
      comment = "Happ proxy client (VLESS/VMess/Trojan/Shadowsocks)";
      terminal = false;
      categories = [ "Utility" ];
    })
  ];

  # HWID Happ читает из /var/lib/dbus/machine-id; dbus-broker его не создаёт.
  systemd.tmpfiles.rules = [
    "L+ /var/lib/dbus/machine-id - - - - /etc/machine-id"
  ];

  networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = [ "tun0" ];
  boot.kernelModules = [ "tun" ];

  systemd.services.happd = {
    description = "Happ Process Control Daemon (manual /opt/happ)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
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
