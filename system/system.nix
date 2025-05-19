{
  zramSwap.enable = true;
  system = {
    stateVersion = "25.05";
  };
  swapDevices = [
    {
      size = 2 * 1024;
      device = "/swapfile";
      randomEncryption.enable = true;
    }
  ];
  fileSystems."/".options = [
    "noatime"
    "nodiratime"
    "lazytime"
    "discard"
  ];
}
