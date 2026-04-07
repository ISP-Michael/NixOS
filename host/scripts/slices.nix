{
  systemd = {
    slices = {
      "Michael" = {
        sliceConfig = {
          CPUQuota = "600%";
        };
      };
    };
  };
}
