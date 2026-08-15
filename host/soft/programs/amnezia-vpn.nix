{
  ...
}:
{
  # Выключено 2026-08-14: перешли на официальный инсталлятор 5.0.0.5 (.run -> /opt/AmneziaVPN).
  # Nix-юнит AmneziaVPN.service конфликтовал с юнитом из post_install.sh инсталлятора.
  # Вернуть обратно: включить модуль и убрать .run-установку из /opt.
  programs = {
    amnezia-vpn = {
      enable = false;
    };
  };
}
