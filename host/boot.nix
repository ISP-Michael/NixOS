{
  pkgs,
  ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "amdgpu.dcdebugmask=0x40000"
      "amdgpu.ppfeaturemask=0xfffffeff"
      "iomem=relaxed"
      "preempt=full"
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
  services = {
    udev = {
      # ntsync is created root-only; "uaccess" gives the logged-in user
      # access to /dev/ntsync without a world-writable device.
      extraRules = ''
        KERNEL=="ntsync", TAG+="uaccess"
      '';
    };
  };
}
