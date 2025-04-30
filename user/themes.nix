{ pkgs, ... }:
{
  gtk = with pkgs; {
    enable = true;
    theme = {
      package = flat-remix-gtk;
      name = "Flat-Remix-GTK-Cyan-Dark";
    };
    iconTheme = {
      name = "Adwaita";
      package = adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Nordzy-cursors-white";
      package = nordzy-cursor-theme;
      size = 36;
    };
    font = {
      size = 14;
      name = "Noto Sans";
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
}
