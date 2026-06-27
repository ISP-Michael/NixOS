{
  networking = {
    hostName = "MagicBook";
    enableIPv6 = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "9.9.9.9"
      "1.0.0.1"
    ];
    networkmanager = {
      enable = true;
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
