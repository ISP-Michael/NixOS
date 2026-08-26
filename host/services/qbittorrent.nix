let
  qbtUid = 520;
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
          Restart = "on-failure";
          RestartSec = 30;
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
