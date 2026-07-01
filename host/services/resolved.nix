{
  services = {
    resolved = {
      enable = true;
      settings = {
        Resolve = {
          DNSSEC = false;
          DNSOverTLS = false;
        };
      };
    };
  };
}
