{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Ручные /opt-приложения (Throne, Happ, AmneziaVPN) и TUN-клиенты
  # требуют модуль tun и разрешают трафик через tun0.
  boot.kernelModules = [
    "tun"
  ];

  networking.firewall = {
    checkReversePath = lib.mkForce (
      if config.iso.agent.enable then
        "loose"
      else
        "strict"
    );
    trustedInterfaces = [
      "tun0"
    ];
  };

  # Happ читает HWID из /var/lib/dbus/machine-id; dbus-broker его не создаёт.
  systemd.tmpfiles.rules = [
    "L+ /var/lib/dbus/machine-id - - - - /etc/machine-id"
  ];

  # OpenClaw/OpenCode ставятся в пользовательский prefix, а не в /nix/store.
  programs.npm = lib.mkIf config.iso.agent.enable {
    enable = true;
    package = pkgs.nodejs_latest;
    npmrc = ''
      prefix = ''${HOME}/.npm
      color=true
    '';
  };

  # OpenCode/OpenClaw ходят в SearXNG на localhost:8888.
  services.searx = lib.mkIf config.iso.agent.enable {
    enable = true;
    package = import ../apps/searxng/package.nix { inherit pkgs; };
    settings = {
      server = {
        bind_address = "127.0.0.1";
        port = 8888;
        secret_key = "nixos-live-searx";
        limiter = false;
      };
      search = {
        safe_search = 0;
        formats = [
          "html"
          "json"
        ];
      };
    };
  };
}
