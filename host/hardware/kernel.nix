{
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
}
