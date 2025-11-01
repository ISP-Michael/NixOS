{
  pkgs,
  unstable-pkgs,
  ...
}:
{
  boot = {
    kernelPackages = unstable-pkgs.linuxPackages_zen;
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
