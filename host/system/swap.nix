{
  zramSwap.enable = true;
  swapDevices = [
    {
      size                    =    2 * 1024;
      device                  = "/swapfile";
      randomEncryption.enable =        true;
    }
  ];
}
