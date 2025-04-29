{
  system = {
    stateVersion = "25.05";
  };
  swapDevices = [
    {
      device = "/swapfile";
      size = 2 * 1024;
      randomEncryption.enable = true;
    }
  ];
  zramSwap.enable = true;
}
