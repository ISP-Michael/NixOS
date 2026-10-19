{
  config,
  pkgs,
  ...
}:
{
  xdg = {
    enable = true;

    # «Показать в папке» (D-Bus org.freedesktop.FileManager1) — всегда
    # Dolphin: у Thunar точно такое же имя, а кто победит — решает
    # порядок чтения каталога сервисов. force перекрывает ручной файл.
    dataFile."dbus-1/services/org.freedesktop.FileManager1.service" = {
      force = true;
      text = ''
        [D-BUS Service]
        Name=org.freedesktop.FileManager1
        Exec=${pkgs.kdePackages.dolphin}/bin/dolphin --daemon
      '';
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Data/Desktop";
      documents = "${config.home.homeDirectory}/Data/Documents";
      download = "${config.home.homeDirectory}/Data/Downloads";
      music = "${config.home.homeDirectory}/Data/Music";
      pictures = "${config.home.homeDirectory}/Data/Pictures";
      projects = "${config.home.homeDirectory}/Data/Projects";
      publicShare = "${config.home.homeDirectory}/Data/Public";
      templates = "${config.home.homeDirectory}/Data/Templates";
      videos = "${config.home.homeDirectory}/Data/Videos";
    };
  };
}
