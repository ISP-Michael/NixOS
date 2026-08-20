{
  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/octet-stream"     = [            "nvim.desktop" ];
        "application/pdf"              = [         "zathura.desktop" ];
        "application/sql"              = [            "nvim.desktop" ];
        "application/x-extension-htm"  = [            "zen.desktop"  ];
        "application/x-extension-html" = [            "zen.desktop"  ];
        "application/xhtml+xml"        = [            "zen.desktop"  ];
        "image/gif"                    = [             "imv.desktop" ];
        "image/jpeg"                   = [             "imv.desktop" ];
        "image/png"                    = [             "imv.desktop" ];
        "image/webp"                   = [             "imv.desktop" ];
        "text/html"                    = [            "zen.desktop"  ];
        "text/markdown"                = [        "obsidian.desktop" ];
        "text/plain"                   = [            "nvim.desktop" ];
        "text/x-readme"                = [        "obsidian.desktop" ];
        "text/x-shellscript"           = [            "nvim.desktop" ];
        "video/mp4"                    = [             "mpv.desktop" ];
        "video/webm"                   = [             "mpv.desktop" ];
        "video/x-matroska"             = [             "mpv.desktop" ];
        "x-scheme-handler/http"        = [             "zen.desktop" ];
        "x-scheme-handler/https"       = [             "zen.desktop" ];
        "x-scheme-handler/tg"          = [        "telegram.desktop" ];
        "x-scheme-handler/tonsite"     = [        "telegram.desktop" ];
        "inode/directory"              = [ "org.kde.dolphin.desktop" ];
      };
    };
  };
}
