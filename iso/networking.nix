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
    };
  };

  # SSH на live не включаем: пользователь Michael с пустым паролем,
  # открытый 22-й порт — лишний риск. Если нужен доступ по сети,
  # включай openssh вручную и задавай ключи/пароль.
}
