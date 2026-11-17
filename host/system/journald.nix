{
  services = {
    journald = {
      settings = {
        Journal = {
          SystemMaxUse = "1G";
          SyncIntervalSec = "5s";
        };
      };
    };
  };
}
