{ pkgs, ... }:
{
  services = {
    blueman.enable    = true;
    libinput.enable   = true;
    resolved.enable   = true;
    postgresql.enable = true;
    pipewire = {
      enable       = true;
      alsa.enable  = true;
      pulse.enable = true;
      audio.enable = true;
      extraConfig.pipewire = {
        "context.properites" = {
          "module.suspend-on-idle.timeout" = 0;
        };
      };
    };
    mysql = {
      enable  = true;
      package = pkgs.mariadb;
    };
  };
}
