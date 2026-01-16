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
      allowedTCPPorts = [
        4533
        8686
        9696
        8080
      ];
    };
  };
}
