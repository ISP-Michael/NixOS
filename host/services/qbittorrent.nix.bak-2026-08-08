{
  pkgs,
  config,
  ...
}:
let
  qbtUid = 520;
  dnsUid = config.ids.uids.systemd-resolve;
  bypassTable = "10011";
  ip = "${pkgs.iproute2}/bin/ip";
  awk = "${pkgs.gawk}/bin/awk";

  # Fail-closed bypass: every connection from the dedicated qbittorrent user
  # is routed through the physical (non-VPN) default route, never via amn0.
  # The ip rule matches on uid during the connect() route lookup (flowi4_uid),
  # so unlike a fwmark set in the OUTPUT hook, it cannot be beaten by the
  # socket route cache.
  #
  # The blackhole rule right after the lookup rule closes the fail-open gap:
  # if table 10011 is ever empty, fib lookup continues into the main table,
  # which routes via amn0. With the blackhole fallback, uid-matching traffic
  # is dropped instead of leaking into the tunnel. Same scheme covers the
  # systemd-resolved uid so DNS queries never leave via the VPS either.
  # If the physical default is missing the script fails, which fails the
  # unit: qbittorrent must not start when bypass is impossible.
  bypassScript = pkgs.writeShellScript "qbittorrent-bypass.sh" ''
    set -euo pipefail
    ${ip} rule del uidrange ${toString qbtUid}-${toString qbtUid} pref 1 lookup ${bypassTable} 2>/dev/null || true
    ${ip} rule del uidrange ${toString qbtUid}-${toString qbtUid} pref 2 blackhole 2>/dev/null || true
    ${ip} rule del uidrange ${toString dnsUid}-${toString dnsUid} pref 3 lookup ${bypassTable} 2>/dev/null || true
    ${ip} rule del uidrange ${toString dnsUid}-${toString dnsUid} pref 4 blackhole 2>/dev/null || true
    ${ip} rule add uidrange ${toString qbtUid}-${toString qbtUid} pref 1 lookup ${bypassTable}
    ${ip} rule add uidrange ${toString qbtUid}-${toString qbtUid} pref 2 blackhole
    ${ip} rule add uidrange ${toString dnsUid}-${toString dnsUid} pref 3 lookup ${bypassTable}
    ${ip} rule add uidrange ${toString dnsUid}-${toString dnsUid} pref 4 blackhole
    phys=$(${ip} route show table main | ${awk} '$1 == "default" && $0 !~ / amn0 / { $1 = "0.0.0.0/0"; print; exit }')
    if [ -z "$phys" ]; then
      echo "no physical default route found, refusing to start qbittorrent" >&2
      exit 1
    fi
    # shellcheck disable=SC2086
    ${ip} route replace $phys table ${bypassTable}
  '';
in
{
  services = {
    qbittorrent = {
      enable = true;
      webuiPort = 8080;
      torrentingPort = 52000;
      openFirewall = true;
    };
  };
  users = {
    users = {
      qbittorrent = {
        uid = qbtUid;
        group = "qbittorrent";
      };
    };
  };
  systemd = {
    services = {
      qbittorrent = {
        serviceConfig = {
          # "+" is required: ExecStartPre otherwise runs as User=qbittorrent
          # and cannot touch ip rules/routes.
          ExecStartPre = "+${bypassScript}";
        };
      };
    };
  };
  networking = {
    firewall = {
      allowedUDPPorts = [
        52000
      ];
    };
  };
}
