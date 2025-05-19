{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg"                   = [ "imv.desktop" ];
      "image/png"                    = [ "imv.desktop" ];
      "image/gif"                    = [ "imv.desktop" ];
      "image/webp"                   = [ "imv.desktop" ];
      "video/mp4"                    = [ "mpv.desktop" ];
      "video/webm"                   = [ "mpv.desktop" ];
      "video/x-matroska"             = [ "mpv.desktop" ];
      "application/sql"              = [ "nvim.desktop" ];
      "application/octet-stream"     = [ "nvim.desktop" ];
      "text/plain"                   = [ "nvim.desktop" ];
      "text/x-shellscriipt"          = [ "nvim.desktop" ];
      "x-scheme-handler/http"        = [ "firefox.desktop" ];
      "x-scheme-handler/https"       = [ "firefox.desktop" ];
      "text/html"                    = [ "firefox.desktop" ];
      "application/x-extension-htm"  = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/xhtml+xml"        = [ "firefox.desktop" ];
      "text/markdown"                = [ "obsidian.desktop" ];
      "text/x-readme"                = [ "obsidian.desktop" ];
      "x-scheme-handler/tg"          = [ "telegram.desktop" ];
      "x-scheme-handler/tonsite"     = [ "telegram.desktop" ];
      "inode/directory"              = [ "yazi.desktop" "thunar.desktop" "org.gnome.Nautilus.desktop" ];
    };
  };
  xdg.configFile."mimeapps.list".force = true;
}
