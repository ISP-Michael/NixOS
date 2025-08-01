{
  pkgs,
  _05-pkgs,
  config,
  ...
}:
{
  boot = {
    kernelPackages = _05-pkgs.linuxPackages_6_1;
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
