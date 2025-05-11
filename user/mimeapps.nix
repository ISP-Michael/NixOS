{
  xdg.configFile."mimeapps.list" = {
    enable = true;
    text = ''
      [Default Applications]
      x-scheme-handler/tg=userapp-AyuGram Desktop-GQJ952.desktop
      x-scheme-handler/tonsite=userapp-AyuGram Desktop-ZB1752.desktop
      x-scheme-handler/http=firefox.desktop
      x-scheme-handler/https=firefox.desktop
      x-scheme-handler/chrome=firefox.desktop
      text/html=firefox.desktop
      application/x-extension-htm=firefox.desktop
      application/x-extension-html=firefox.desktop
      application/x-extension-shtml=firefox.desktop
      application/xhtml+xml=firefox.desktop
      application/x-extension-xhtml=firefox.desktop
      application/x-extension-xht=firefox.desktop
      x-scheme-handler/about=firefox.desktop
      x-scheme-handler/unknown=firefox.desktop
      application/pdf=firefox.desktop
      inode/directory=yazi.desktop
      text/plain=nvim.desktop

      [Added Associations]
      x-scheme-handler/tg=org.telegram.desktop.desktop;userapp-Telegram Desktop-ARN602.desktop;userapp-AyuGram Desktop-GQJ952.desktop;
      x-scheme-handler/tonsite=org.telegram.desktop.desktop;userapp-Telegram Desktop-2QF702.desktop;userapp-AyuGram Desktop-ZB1752.desktop;
      x-scheme-handler/http=firefox.desktop;
      x-scheme-handler/https=firefox.desktop;
      x-scheme-handler/chrome=firefox.desktop;
      text/html=firefox.desktop;
      application/x-extension-htm=firefox.desktop;
      application/x-extension-html=firefox.desktop;
      application/x-extension-shtml=firefox.desktop;
      application/xhtml+xml=firefox.desktop;
      application/x-extension-xhtml=firefox.desktop;
      application/x-extension-xht=firefox.desktop;
      image/jpeg=imv.desktop;
      text/plain=nvim.desktop;
    '';
  };
}
