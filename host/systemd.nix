{
  systemd = {
    user = {
      # цель-прослойка: ее запуск активирует graphical-session.target (его нет
      # без DM/uwsm), иначе фронтенд порталов не стартует из-за Requisite
      targets.hyprland-session = {
        description = "Hyprland session";
        bindsTo = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
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
