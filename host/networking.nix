{
  networking = {
    hostName = "MagicBook";
    enableIPv6 = true;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "1.0.0.1"
      "9.9.9.9"
    ];
    networkmanager = {
      enable = true;
      wifi = {
        scanRandMacAddress = false;
      };
    };
    firewall = {
      enable = true;
      # WARP HTTP-прокси (usque) для SearXNG в Docker: контейнер ходит на
      # 172.17.0.1:8088, иначе NixOS-фаервол режет INPUT с docker0.
      extraInputRules = ''
        ip saddr 172.17.0.0/16 tcp dport 8088 accept
      '';
      interfaces = {
        virbr0 = {
          allowedTCPPorts = [
            37963
          ];
        };
      };
    };
  };
}
