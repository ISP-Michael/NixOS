{
  pkgs,
  ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "amdgpu.dcdebugmask=0x40000"
    ];

    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
  };
}
