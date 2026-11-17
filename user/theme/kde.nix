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
    packages = [
      applyKdeTheme
    ];
    activation.applyKdeTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${applyKdeTheme}/bin/apply-kde-theme || true
    '';
  };

  xdg.configFile = {
    "noctalia/apply-kde.sh".source = "${applyKdeTheme}/bin/apply-kde-theme";
  };
}
