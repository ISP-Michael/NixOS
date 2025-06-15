{
  systemd.services.chmod = {
    wantedBy = [ "multi-user.target" ];
    after    = [ "network.target" ];
    serviceConfig = {
      Type      = "oneshot";
      execStart = "/etc/chmod.sh";
      User      = "root";
    };
  };
}
