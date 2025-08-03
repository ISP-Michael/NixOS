{
  pkgs,
  _05-pkgs,
  config,
  ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_6_14;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
    kernelParams = [
      "nvme_core.default_ps_max_latency_us=0"
    ];
    kernelModules = [
      "zenergy"
    ];
    extraModulePackages = [
      config.boot.kernelPackages.zenergy
    ];
  };
}
