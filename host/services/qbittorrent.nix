{
  pkgs,
  ...
}:
let
  qbtUid = 520;
  bypassTable = "10011";
  ip = "${pkgs.iproute2}/bin/ip";
  awk = "${pkgs.gawk}/bin/awk";
  nft = "${pkgs.nftables}/bin/nft";

  # Fail-closed bypass: every connection from the dedicated qbittorrent user
  # (IPv4 AND IPv6) is routed through the physical (non-VPN) default route,
  # never via any VPN tunnel (AmneziaWG "amn0", Xray "throne-tun", ...).
  # The ip rule matches on uid during the connect() route lookup
  # (flowi4_uid), so unlike a fwmark set in the OUTPUT hook, it cannot be
  # beaten by the socket route cache.
  #
  # The blackhole rule right after the lookup rule closes the fail-open gap:
  # if table 10011 is ever empty, fib lookup continues into the main table,
  # which routes via the VPN tunnel. With the blackhole fallback,
  # uid-matching traffic is dropped instead of leaking into the tunnel.
  #
  # The script is idempotent and safe to re-run. It is executed:
  #  - at qbittorrent start (ExecStartPre, --strict: refuses to start if no
  #    physical default route exists),
  #  - on every NetworkManager event (dispatcher script),
  #  - every 60s by a timer (catches AmneziaVPN reconnects, which NM does not
  #    see and which have been observed to wipe the bypass table).
  #
  # DNS (systemd-resolved) is intentionally NOT bypassed: per policy all
  # non-P2P traffic, DNS included, goes through the VPN tunnel.
  bypassScript = pkgs.writeShellScript "qbittorrent-bypass.sh" ''
    set -euo pipefail
    strict=0
    [ "''${1:-}" = "--strict" ] && strict=1

    for fam in "" "-6"; do
      ${ip} $fam rule del uidrange ${toString qbtUid}-${toString qbtUid} pref 1 lookup ${bypassTable} 2>/dev/null || true
      ${ip} $fam rule del uidrange ${toString qbtUid}-${toString qbtUid} pref 2 blackhole 2>/dev/null || true
      ${ip} $fam rule add uidrange ${toString qbtUid}-${toString qbtUid} pref 1 lookup ${bypassTable}
      ${ip} $fam rule add uidrange ${toString qbtUid}-${toString qbtUid} pref 2 blackhole
      # Cleanup: legacy systemd-resolved bypass rules from the old config
      # (DNS must stay on the VPN per policy; leftover rules would send
      # resolver traffic to the physical route where the VPN DNS server
      # is unreachable).
      ${ip} $fam rule del uidrange 153-153 2>/dev/null || true
    done

    # Collect tunnel-type devices (tun / wireguard). Any default route on such
    # a device is a VPN tunnel (AmneziaWG "amn0", Xray "throne-tun", ...) and
    # must never be used as the qbittorrent bypass route.
    tun_devs="$(${ip} -o link show type tun 2>/dev/null | ${awk} -F': ' '{printf "%s ", $2}')$(${ip} -o link show type wireguard 2>/dev/null | ${awk} -F': ' '{printf "%s ", $2}')"

    phys4=$(${ip} route show table main | ${awk} -v tun="$tun_devs" '
      $1 == "default" {
        dev = ""
        for (i = 1; i <= NF; i++) if ($i == "dev") dev = $(i + 1)
        if (dev != "" && index(tun, dev) == 0) { $1 = "0.0.0.0/0"; print; exit }
      }')
    phys6=$(${ip} -6 route show table main | ${awk} -v tun="$tun_devs" '
      $1 == "default" {
        dev = ""
        for (i = 1; i <= NF; i++) if ($i == "dev") dev = $(i + 1)
        if (dev != "" && index(tun, dev) == 0) { $1 = "::/0"; print; exit }
      }')

    if [ -n "$phys4" ]; then
      # shellcheck disable=SC2086
      ${ip} route replace $phys4 table ${bypassTable}
    else
      ${ip} route flush table ${bypassTable}
    fi

    if [ -n "$phys6" ]; then
      # shellcheck disable=SC2086
      ${ip} -6 route replace $phys6 table ${bypassTable}
    else
      ${ip} -6 route flush table ${bypassTable}
    fi

    if [ -z "$phys4" ] && [ -z "$phys6" ] && [ "$strict" = 1 ]; then
      echo "no physical default route found, refusing to start qbittorrent" >&2
      exit 1
    fi
  '';

  # Block forwarded traffic from other local sources (docker/podman, waydroid)
  # from entering ANY VPN tunnel (AmneziaWG "amn0", Xray "throne-tun", ...).
  # The libvirt VM network (virbr0) is explicitly allowed: the VM is expected
  # to ride the VPN tunnel by policy. Locally generated qbittorrent traffic is
  # already covered by the uid rules above; forwarded traffic has no socket uid
  # and would otherwise ride the main table into the tunnel.
  p2pGuardRules = pkgs.writeText "p2p-guard.nft" ''
    table inet p2pguard {
      chain forward {
        type filter hook forward priority filter; policy accept;
        iifname "virbr0" counter accept
        oifname { "amn0", "throne-tun" } counter drop
      }
      chain outguard {
        type filter hook output priority filter; policy accept;
        meta skuid 520 oifname { "amn0", "throne-tun" } counter drop
      }
    }
  '';
  # nft -f fails with "File exists" if the table is already defined, so wrap
  # it in a delete-then-apply script that is safe on both first run and reload.
  p2pGuardApply = pkgs.writeShellScript "p2p-guard-apply.sh" ''
    ${nft} delete table inet p2pguard 2>/dev/null || true
    ${nft} -f ${p2pGuardRules}
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
        after = [
          "network-online.target"
        ];
        wants = [
          "network-online.target"
        ];
        serviceConfig = {
          # "+" is required: ExecStartPre otherwise runs as User=qbittorrent
          # and cannot touch ip rules/routes.
          ExecStartPre = "+${bypassScript} --strict";
          Restart = "on-failure";
          RestartSec = 30;
        };
      };
      p2p-bypass-refresh = {
        description = "Re-apply qbittorrent VPN bypass rules";
        after = [
          "network.target"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = bypassScript;
        };
      };
      p2pguard = {
        description = "Block forwarded traffic into the VPN tunnel";
        after = [
          "network.target"
        ];
        wantedBy = [
          "multi-user.target"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = p2pGuardApply;
          ExecReload = p2pGuardApply;
        };
      };
    };
    timers = {
      p2p-bypass-refresh = {
        description = "Refresh qbittorrent VPN bypass rules every minute";
        wantedBy = [
          "timers.target"
        ];
        timerConfig = {
          OnBootSec = "30";
          OnUnitActiveSec = "60";
          Unit = "p2p-bypass-refresh.service";
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
    networkmanager = {
      dispatcherScripts = [
        {
          type = "basic";
          source = pkgs.writeShellScript "p2p-bypass-dispatch" ''
            case "$2" in
              up|down|vpn-up|vpn-down|dhcp4-change|dhcp6-change|connectivity-change)
                ${bypassScript} || true
                ;;
            esac
          '';
        }
      ];
    };
  };
}
