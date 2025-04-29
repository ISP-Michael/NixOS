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
      name = "Noto Sans";
      size = 14;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
}
