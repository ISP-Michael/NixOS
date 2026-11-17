{
  # Без rtkit PipeWire не получает SCHED_FIFO и рвётся под нагрузкой.
  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
