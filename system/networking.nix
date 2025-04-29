{
  networking = {
    hostName = "MagicBook";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      checkReversePath = false;
    };
  };
}
