{
  systemd = {
    services = {
      chmod = {
        wantedBy = [ "multi-user.target" ];
        after    = [    "network.target" ];
        serviceConfig = {
          Type      = "oneshot";
          ExecStart = "/etc/_chmod.sh";
          User      = "root";
        };
      };
    };
  };
}
