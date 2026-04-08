{
  services = {
    blueman.enable = true;
    libinput.enable = true;
    postgresql.enable = true;
    udisks2.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
      };
    };
  };
}
