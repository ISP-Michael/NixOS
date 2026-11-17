{
  pkgs,
  ...
}:
let
  updateScript = pkgs.writeShellScript "searxng-update" (
    builtins.readFile ./update.sh
  );
in
{
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        searxng = {
          image = "searxng/searxng:latest";
          ports = [
            "127.0.0.1:8888:8080"
          ];
          volumes = [
            "/home/Michael/.config/searxng:/etc/searxng:ro"
          ];
        };
      };
    };
  };

  # WARP HTTP-прокси (usque) для SearXNG в Docker: контейнер ходит на
  # 172.17.0.1:8088, иначе NixOS-фаервол режет INPUT с docker0.
  networking.firewall.extraInputRules = ''
    ip saddr 172.17.0.0/16 tcp dport 8088 accept
  '';

  systemd = {
    services = {
      searxng-update = {
        description = "Pull latest SearXNG image and restart if changed";
        requires = [
          "docker.service"
        ];
        after = [
          "docker.service"
          "docker-searxng.service"
        ];
        path = [
          pkgs.docker
          pkgs.curl
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${updateScript}";
          StateDirectory = "searxng-update";
          TimeoutStartSec = "10min";
        };
      };
    };
    timers = {
      searxng-update = {
        description = "Daily SearXNG image update";
        wantedBy = [
          "timers.target"
        ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };
    };
  };
}
