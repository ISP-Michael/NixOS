{
  lib,
  ...
}:
{
  zramSwap = {
    enable = true;
    memoryPercent = 80;
  };

  # disko's swapfile.size is used only when disko creates the file at
  # install time.  NixOS itself needs the size in swapDevices: otherwise
  # it never notices that the existing file is 16G instead of 8G and
  # never recreates it.  With this the mkswap unit fixes the size on boot.
  swapDevices = lib.mkForce [
    {
      device = "/.swapvol/swapfile";
      size = 8192;
    }
  ];
}
