{
  systemd = {
    user = {
      # цель-прослойка: ее запуск активирует graphical-session.target (его нет
      # без DM/uwsm), иначе фронтенд порталов не стартует из-за Requisite
      targets.hyprland-session = {
        description = "Hyprland session";
        bindsTo = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        # Агент авторизации polkit: диалоги запрашивают пароль/отпечаток.
        # Через systemd у него чистое окружение — при запуске из Hyprland в него
        # попадают QT_STYLE_OVERRIDE=kvantum и прочее, и QML-диалог падает
        # с ошибкой QQuickStyle.
        wants = [ "hyprpolkitagent.service" ];
      };
      services = {
        xdg-desktop-portal-hyprland = {
          serviceConfig = {
            Environment = [
              "QT_QPA_PLATFORMTHEME="
              "QT_STYLE_OVERRIDE="
              "R600_DEBUG=nodcc"
            ];
          };
        };
      };
    };
  };
}
