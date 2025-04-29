{ pkgs, ... }:
{
  services = {
    blueman.enable = true;
    libinput.enable = true;
    resolved.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };
    postgresql.enable = true;
  };
}
