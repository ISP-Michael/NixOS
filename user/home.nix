{
  pkgs,
  ...
}:
{
  home = {
    username = "Michael";
    stateVersion = "25.11";
    homeDirectory = "/home/Michael";
    sessionVariables = {
      EDITOR = "nvim";
      TELEGA_SERVER_LIBS_API_ID = "21709460";
      TELEGA_SERVER_LIBS_API_HASH = "26b7c950ed1f12dfcb4c24578025e89b";
    };
    packages = with pkgs; [
      glib
      gtk3
    ];
  };
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu";
      };
    };
  };
  manual = {
    manpages = {
      enable = false;
    };
  };
}
