{
  # mihomo — AmneziaWG 3.1 + geoip-ru / geosite-ru
  #
  # Сам конфиг — обычный файл рядом, в /etc/nixos/host/services/mihomo.yaml.
  # Он НЕ в git (см. .gitignore): там приватный ключ и pre-shared key туннеля.
  # Путь абсолютный и намеренно: относительный ./mihomo.yaml флайк взял бы
  # из своего источника, а туда попадают только git-отслеживаемые файлы.
  services.mihomo = {
    enable = true;

    # Обязательный параметр. Файл читается на этапе сборки, поэтому он должен
    # существовать на диске уже сейчас — иначе будет ошибка сборки.
    configFile = /etc/nixos/host/services/mihomo.yaml;

    # Нужны права CAP_NET_ADMIN, чтобы mihomo создал TUN-устройство.
    # ВНИМАНИЕ: опция только выдаёт capability. Сам TUN включается в конфиге
    # (там блок `tun: enable: true`) — модуль об этом пишет в описании.
    tunMode = true;

    # Нужно для правил вида `process-name` — mihomo должен видеть процессы.
    # Сейчас не используется, поэтому выключено: лишние два capability
    # (CAP_DAC_READ_SEARCH и CAP_SYS_PTRACE) не нужны.
    processesInfo = false;

    # Веб-интерфейс для статистики. Раскомментируй, если хочешь:
    #   webui = pkgs.metacubexd;
    # Либо пользуйся онлайн: https://d.metacubex.one
  };
}