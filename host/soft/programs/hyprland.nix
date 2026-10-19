{
  inputs,
  pkgs,
  system,
  ...
}:
{
  programs = {
    hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      xwayland = {
        enable = true;
      };
    };
  };

  # Порталы сессии. Выбор файлов отдаём KDE-бэкенду — диалоги выглядят как
  # в Dolphin (Places, хлебные крошки), остальные интерфейсы — hyprland, затем gtk.
  # Конфиг ляжет в /etc/xdg/xdg-desktop-portal/hyprland-portals.conf,
  # KDE-бэкенд — в системные пакеты (юнит в /etc/systemd/user, D-Bus-активация).
  xdg.portal = {
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.hyprland = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
    };
  };
}
