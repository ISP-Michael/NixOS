{
  ...
}:
{
  # Выключено 2026-08-14: перешли на официальный инсталлятор (.run -> /opt/AmneziaVPN).
  # Актуальная версия и шаги обновления — topics/amnezia.md.
  # Nix-юнит AmneziaVPN.service конфликтовал с юнитом из post_install.sh инсталлятора.
  # Вернуть обратно: включить модуль и убрать .run-установку из /opt.
  programs = {
    amnezia-vpn = {
      enable = false;
    };
  };
}
