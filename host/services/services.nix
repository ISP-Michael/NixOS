{
  services = {
    blueman.enable = true;
    libinput.enable = true;
    postgresql.enable = true;

    resolved = {
      enable = true;
      dnssec = "false";
      dnsovertls = "false";
      fallbackDns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };
}
