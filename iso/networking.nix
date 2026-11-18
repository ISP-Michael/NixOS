{
  config,
  lib,
  ...
}:
{
  options.iso.hostName = lib.mkOption {
    type = lib.types.str;
    default = "nixos-live";
    description = "Имя live-системы в сети.";
  };

  config = {
    networking = {
      hostName = config.iso.hostName;
      networkmanager = {
        enable = true;
        wifi = {
          scanRandMacAddress = false;
        };
      };
      firewall = {
        enable = true;
      };
    };

    # SSH на live не включаем: пользователь с пустым паролем,
    # открытый 22-й порт — лишний риск. Включай вручную при необходимости.
  };
}
