{
  networking = {
    hostName = "MagicBook";

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
