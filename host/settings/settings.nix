{
  pkgs,
  unstable-pkgs,
  ...
}:
{
  nix = {
    package = unstable-pkgs.lixPackageSets.latest.lix;
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      cores = 2;
      max-jobs = 2;
      warn-dirty = false;
      auto-optimise-store = false;
      always-allow-substitutes = true;
      max-substitution-jobs = 16;
      min-free = "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = "${toString (10 * 1024 * 1024 * 1024)}";
    };
    optimise = {
      automatic = true;
      dates = [
        "12:00"
      ];
    };
  };
  boot = {
    kernelModules = [
      "tcp_bbr"
    ];
    kernel = {
      sysctl = {
        "vm.swappiness" = 10;
        "vm.dirty_background_ratio" = 5;
        "vm.dirty_ratio" = 10;
        "vm.vfs_cache_pressure" = 50;
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
    };
  };
  powerManagement = {
    cpuFreqGovernor = "powersave";
  };
}
