{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.amnezia-vpn;
in
{
  options.services.amnezia-vpn = {
    enable = lib.mkEnableOption "AmneziaVPN client (manual /opt or store package)";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Pinned installer package for ISO; null for manual /opt on the host.";
    };

    installToOpt = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Run the official .run installer into /opt/AmneziaVPN at activation.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.installToOpt || cfg.package != null;
        message = "services.amnezia-vpn.installToOpt требует services.amnezia-vpn.package.";
      }
    ];

    # Декларативный юнит для .run-установки AmneziaVPN в /opt/AmneziaVPN.
    # post_install.sh инсталлятора не смог записать юнит сам:
    # /etc/systemd/system на NixOS — read-only симлинк на /etc/static/systemd/system.
    # PATH обязателен: без /run/current-system/sw/bin сервис не находит
    # ip/iptables/ip6tables, активация tun падает (ошибка 101 InternalError).
    systemd.services.AmneziaVPN = {
      description = "AmneziaVPN Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        ConditionPathExists = "/opt/AmneziaVPN/bin/AmneziaVPN-service";
      };
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1";
        ExecStart = "/opt/AmneziaVPN/bin/AmneziaVPN-service";
        Environment = [
          "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
          "NIX_LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib"
        ];
      };
    };

    environment.systemPackages = [
      pkgs.iproute2
      pkgs.iptables
      (pkgs.writeShellScriptBin "amnezia-vpn" ''
        if [ ! -x /opt/AmneziaVPN/bin/AmneziaVPN ]; then
          echo "AmneziaVPN не установлен: нет /opt/AmneziaVPN/bin/AmneziaVPN" >&2
          exit 1
        fi
        exec env NIX_LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib /opt/AmneziaVPN/bin/AmneziaVPN "$@"
      '')
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

    # ISO: ставим pinned .run из store. Host: установка официальным
    # установщиком в /opt (installToOpt = false), обновление — update.sh.
    system.activationScripts.amneziaInstall = lib.mkIf cfg.installToOpt ''
      stamp=/opt/AmneziaVPN/.nix-version
      want="${cfg.package}"
      if [ "$(cat "$stamp" 2>/dev/null)" != "$want" ]; then
        backup="/opt/AmneziaVPN.bak-$(date +%Y%m%d-%H%M%S)"
        if [ -e /opt/AmneziaVPN ]; then
          mv /opt/AmneziaVPN "$backup" || true
        fi
        mkdir -p /opt/AmneziaVPN
        if ! QT_QPA_PLATFORM=offscreen HOME=/root \
          PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin:/usr/bin:/bin \
          ${cfg.package}/share/amnezia-vpn/AmneziaVPN.run \
          --root /opt/AmneziaVPN \
          --accept-licenses \
          --default-answer \
          --confirm-command install; then
          rm -rf /opt/AmneziaVPN
          [ -d "$backup" ] && mv "$backup" /opt/AmneziaVPN
          echo "AmneziaVPN install failed; rolled back" >&2
        else
          printf '%s' "$want" > /opt/AmneziaVPN/.nix-version
          chmod -R a-w /opt/AmneziaVPN 2>/dev/null || true
        fi
      fi
    '';
  };
}
