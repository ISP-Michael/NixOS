{
  pkgs,
  ...
}:
{
  virtualisation = {
    docker = {
      enable = true;
      # VPN-туннель amn0 имеет MTU 1376, а docker0 по умолчанию 1500.
      # Пакеты больше 1376 дропаются, TLS-handshake из контейнеров висит
      # до таймаута. Держим MTU bridge не выше туннеля.
      daemon = {
        settings = {
          mtu = 1376;
        };
      };
    };
    libvirtd = {
      enable = true;
    };
    spiceUSBRedirection = {
      enable = true;
    };
  };
}
