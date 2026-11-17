{
  lib,
  ...
}:
{
  networking = {
    hostName = "nixos-live";
    networkmanager = {
      enable = true;
      wifi = {
        scanRandMacAddress = false;
      };
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
      ];
    };
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        # На live-ISO root без пароля — SSH снаружи должен быть закрыт.
        PermitRootLogin = lib.mkForce "no";
        PasswordAuthentication = true;
      };
    };
  };
}
