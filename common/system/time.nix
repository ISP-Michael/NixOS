{
  time = {
    timeZone = "Europe/Moscow";
  };

  services = {
    chrony = {
      enable = true;
      # NTS выключен намеренно: пулы *.nixos.pool.ntp.org не держат
      # NTS-KE (TCP/4460), включение ломает синхронизацию.
      enableNTS = false;
    };
  };
}
