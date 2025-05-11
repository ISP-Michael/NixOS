{ pkgs, ... }:
{
  services = {
    blueman.enable    = true;
    libinput.enable   = true;
    resolved.enable   = true;
    postgresql.enable = true;
    pipewire = {
      enable       = true;
      pulse.enable = true;
    };
    mysql = {
      enable  = true;
      package = pkgs.mariadb;
    };
  };
}
