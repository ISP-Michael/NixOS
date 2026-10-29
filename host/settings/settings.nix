{
  pkgs,
  ...
}:
{
  nix = {
    package = pkgs.lixPackageSets.latest.lix;
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      cores = 4;
      max-jobs = 3;
      warn-dirty = false;
      auto-optimise-store = false;
      always-allow-substitutes = true;
      extra-deprecated-features = "or-as-identifier";
      max-substitution-jobs = 16;
      keep-outputs = true;
      keep-derivations = true;
      min-free = "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = "${toString (10 * 1024 * 1024 * 1024)}";
    };
    optimise = {
      automatic = true;
      dates = [
        "12:00"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
  boot = {
    kernelModules = [
      "tcp_bbr"
    ];
    kernel = {
      sysctl = {
        "vm.swappiness" = 10;
        "vm.page-cluster" = 3;
        "vm.dirty_background_ratio" = 5;
        "vm.dirty_ratio" = 10;
        "vm.vfs_cache_pressure" = 50;
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
    };
  };
  services = {
    power-profiles-daemon = {
      enable = true;
    };
    scx = {
      enable = true;
      scheduler = "scx_bpfland";
    };
  };
}
