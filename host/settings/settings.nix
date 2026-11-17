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
      # NT synchronization primitives for Proton/Wine (faster than futex).
      "ntsync"
    ];
    kernel = {
      sysctl = {
        "vm.swappiness" = 100;
        # zram is random access: 8-page readahead on swap-in is pure waste.
        "vm.page-cluster" = 0;
        "vm.dirty_background_ratio" = 5;
        "vm.dirty_ratio" = 10;
        "vm.vfs_cache_pressure" = 50;
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        # Full SysRq: if the GPU wedges again, Alt+SysRq+REISUB can reboot
        # cleanly and leave the last kernel messages on disk.
        "kernel.sysrq" = 1;
      };
    };
  };
  systemd = {
    services = {
      # Store maintenance must never compete with a game.
      nix-optimise = {
        serviceConfig = {
          Nice = 19;
          IOSchedulingClass = "idle";
          CPUSchedulingPolicy = "idle";
        };
      };
      nix-gc = {
        serviceConfig = {
          Nice = 19;
          IOSchedulingClass = "idle";
          CPUSchedulingPolicy = "idle";
        };
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
