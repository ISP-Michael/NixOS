{
  networking = {
    hostName = "MagicBook";
    enableIPv6 = false;
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi = {
        scanRandMacAddress = false;
      };
    };
    firewall = {
      enable = true;
      checkReversePath = false;
    };
  };
}
