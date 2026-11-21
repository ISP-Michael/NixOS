{
  config,
  pkgs,
  ...
}:
{
  xdg = {
    enable = true;

    mime = {
      sharedMimeInfoPackage = pkgs.lib.hiPrio pkgs.shared-mime-info;
    };

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

    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/octet-stream" = [ "nvim.desktop" ];
        "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
        "application/sql" = [ "nvim.desktop" ];
        "application/x-extension-htm" = [ "zen.desktop" ];
        "application/x-extension-html" = [ "zen.desktop" ];
        "application/xhtml+xml" = [ "zen.desktop" ];
        "image/gif" = [ "imv.desktop" ];
        "image/jpeg" = [ "imv.desktop" ];
        "image/png" = [ "imv.desktop" ];
        "image/webp" = [ "imv.desktop" ];
        "text/html" = [ "zen.desktop" ];
        "text/markdown" = [ "md.obsidian.Obsidian.desktop" ];
        "text/plain" = [ "nvim.desktop" ];
        "text/x-readme" = [ "md.obsidian.Obsidian.desktop" ];
        "text/x-shellscript" = [ "nvim.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "x-scheme-handler/http" = [ "zen.desktop" ];
        "x-scheme-handler/https" = [ "zen.desktop" ];
        "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
        "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
        "inode/directory" = [ "org.kde.dolphin.desktop" ];
      };
    };

    # xdg.desktopEntries в текущем Home Manager сломан (option extraConfig
    # удалён, но модуль его всё ещё выставляет). Пишем файл напрямую.
    dataFile."applications/unciv.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Unciv
      Exec=unciv --data-dir=${config.home.homeDirectory}/.local/share/unciv
      Icon=unciv
      Categories=Game;
      Comment=An open-source Android/Desktop remake of Civ V
    '';
  };
}
