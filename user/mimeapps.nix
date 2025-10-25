{
  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/octet-stream"     = [            "nvim.desktop" ];
        "application/pdf"              = [         "zathura.desktop" ];
        "application/sql"              = [            "nvim.desktop" ];
        "application/x-extension-htm"  = [         "firefox.desktop" ];
        "application/x-extension-html" = [         "firefox.desktop" ];
        "application/xhtml+xml"        = [         "firefox.desktop" ];
        "image/gif"                    = [             "imv.desktop" ];
        "image/jpeg"                   = [             "imv.desktop" ];
        "image/png"                    = [             "imv.desktop" ];
        "image/webp"                   = [             "imv.desktop" ];
        "text/html"                    = [         "firefox.desktop" ];
        "text/markdown"                = [        "obsidian.desktop" ];
        "text/plain"                   = [            "nvim.desktop" ];
        "text/x-readme"                = [        "obsidian.desktop" ];
        "text/x-shellscriipt"          = [            "nvim.desktop" ];
        "video/mp4"                    = [             "mpv.desktop" ];
        "video/webm"                   = [             "mpv.desktop" ];
        "video/x-matroska"             = [             "mpv.desktop" ];
        "x-scheme-handler/http"        = [         "firefox.desktop" ];
        "x-scheme-handler/https"       = [         "firefox.desktop" ];
        "x-scheme-handler/tg"          = [        "telegram.desktop" ];
        "x-scheme-handler/tonsite"     = [        "telegram.desktop" ];
        "inode/directory"              = [ "org.kde.dolphin.desktop" ];
      };
    };
  };
}
