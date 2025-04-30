{
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
  zramSwap.enable = true;
}
