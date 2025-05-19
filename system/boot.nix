{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable             = true;
        configurationLimit = 5;
      };
    };
    blacklistedKernelModules = [
      "uvcvideo"
    ];
    kernelParams = [
      "nvme_core.default_ps_max_latency_us=0"
    ];
  };
}
