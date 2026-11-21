{
  pkgs,
  ...
}:
{
  home = {
    pointerCursor = {
      enable = true;
      name = "Nordzy-cursors-white";
      package = pkgs.nordzy-cursor-theme;
      size = 36;
      gtk.enable = true;
      x11.enable = true;
    };

    packages = with pkgs; [
      adw-gtk3
      dejavu_fonts
      nerd-fonts.fira-code
      nordzy-cursor-theme
      nordzy-icon-theme
      noto-fonts-color-emoji
    ];
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    font = {
      name = "DejaVu Sans";
      size = 12;
      package = pkgs.dejavu_fonts;
    };
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Nordzy-purple-dark";
      package = pkgs.nordzy-icon-theme;
    };
    cursorTheme = {
      name = "Nordzy-cursors-white";
      package = pkgs.nordzy-cursor-theme;
      size = 36;
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "DejaVu Sans"
      ];
      serif = [
        "DejaVu Serif"
      ];
      monospace = [
        "FiraCode Nerd Font NDD"
      ];
      emoji = [
        "Noto Color Emoji"
      ];
    };
  };
}
