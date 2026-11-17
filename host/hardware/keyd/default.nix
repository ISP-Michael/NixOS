{
  services.keyd.enable = true;

  # Конфиг keyd лежит файлом, а не в Nix-атрибутах: слои большие, а
  # keyd чувствителен к синтаксису. environment.etc делает его
  # декларативным без activation-скрипта с путём /etc/nixos.
  environment.etc."keyd/default.conf".source = ./default.conf;

  systemd.services.keyd.restartTriggers = [
    ./default.conf
  ];
}
