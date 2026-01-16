{
  systemd = {
    services = {
      lidarr = {
        serviceConfig = {
          UMask = "0002";
        };
      };
    };
  };
}
