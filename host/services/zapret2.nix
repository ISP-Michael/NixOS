{ pkgs, ... }:
{
  # zapret2 стоит НЕ из nixpkgs, а нативно из upstream в /opt/zapret2
  # (версия 1.0.6, обновляется вручную). Здесь только автозапуск:
  # /etc/systemd/system в NixOS read-only, юнит иначе некуда положить.
  systemd.services.zapret2 = {
    description = "zapret2 DPI bypass (native install in /opt/zapret2)";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "firewall.service" ];

    # init-скрипт зовёт nft/awk/sed/grep/ip/ps — в systemd PATH пустой,
    # без этого правила молча не создаются.
    path = with pkgs; [
      nftables
      gawk
      gnused
      gnugrep
      coreutils
      findutils
      iproute2
      procps
      iptables
    ];

    unitConfig = {
      # перезагрузка nixos-fw не должна оставлять нас без правил
      ReloadPropagatedFrom = "firewall.service";
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/opt/zapret2/init.d/sysv/zapret2 start";
      ExecStop = "/opt/zapret2/init.d/sysv/zapret2 stop";
      ExecReload = "/opt/zapret2/init.d/sysv/zapret2 restart-fw";
    };
  };
}
