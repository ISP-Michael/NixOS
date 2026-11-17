{
  pkgs,
  lib,
  ...
}:
let
  applyKdeTheme = pkgs.writeShellScriptBin "apply-kde-theme" ''
    set -euo pipefail

    kwriteconfig6=${pkgs.kdePackages.kconfig}/bin/kwriteconfig6

    mode="$(noctalia msg theme-mode-get 2>/dev/null | head -1 || true)"
    if [[ "$mode" == "light" ]]; then
      icon_theme="Nordzy-purple"
    else
      icon_theme="Nordzy-purple-dark"
    fi

    # Noctalia writes only the colour sections. These keys are deliberately
    # owned by this script so they survive every palette change.
    "$kwriteconfig6" --file kdeglobals --group KDE --key LookAndFeelPackage --delete --notify
    "$kwriteconfig6" --file kdeglobals --group UiSettings --key ColorScheme --delete --notify

    "$kwriteconfig6" --file kdeglobals --group General --key font "DejaVu Sans,12,-1,5,50,0,0,0,0,0" --notify
    "$kwriteconfig6" --file kdeglobals --group General --key fixed "FiraCode Nerd Font NDD,12,-1,5,50,0,0,0,0,0" --notify
    "$kwriteconfig6" --file kdeglobals --group General --key menuFont "DejaVu Sans,10,-1,5,50,0,0,0,0,0" --notify
    "$kwriteconfig6" --file kdeglobals --group General --key toolBarFont "DejaVu Sans,10,-1,5,50,0,0,0,0,0" --notify
    "$kwriteconfig6" --file kdeglobals --group General --key taskbarFont "DejaVu Sans,10,-1,5,50,0,0,0,0,0" --notify
    "$kwriteconfig6" --file kdeglobals --group General --key smallestReadableFont "DejaVu Sans,10,-1,5,50,0,0,0,0,0" --notify
    "$kwriteconfig6" --file kdeglobals --group General --key desktopFont "DejaVu Sans,10,-1,5,50,0,0,0,0,0" --notify
    "$kwriteconfig6" --file kdeglobals --group WM --key activeFont "DejaVu Sans,10,-1,5,50,0,0,0,0,0" --notify

    "$kwriteconfig6" --file kdeglobals --group Icons --key Theme "$icon_theme" --notify
    "$kwriteconfig6" --file kcminputrc --group Mouse --key cursorTheme "Nordzy-cursors-white" --notify
    "$kwriteconfig6" --file kcminputrc --group Mouse --key cursorSize "36" --notify

    if command -v gsettings >/dev/null 2>&1; then
      gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" 2>/dev/null || true
    fi
  '';
in
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
      applyKdeTheme
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
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
      monospace = [ "FiraCode Nerd Font NDD" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  xdg.configFile = {
    "noctalia/apply-kde.sh".source = "${applyKdeTheme}/bin/apply-kde-theme";
    "noctalia/templates/kcolorscheme.colors".source = ./kcolorscheme.colors;
    "noctalia/templates/picker-palette.json".source = ./picker-palette.json;
  };

  home.activation.applyKdeTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${applyKdeTheme}/bin/apply-kde-theme || true
  '';
}
