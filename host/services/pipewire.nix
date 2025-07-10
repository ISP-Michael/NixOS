{
  services = {
    pipewire = {
      enable       = true;
      alsa.enable  = true;
      pulse.enable = true;
      audio.enable = true;
      extraConfig = {
        pipewire = {
          "context.properites" = {
            "module.suspend-on-idle.timeout" = 0;
          };
        };
      };
    };
  };
}
