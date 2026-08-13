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
      insertNameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      wifi = {
        scanRandMacAddress = false;
      };
    };
    firewall = {
      enable = true;
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
