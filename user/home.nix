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
      YDOTOOL_SOCKET = "/run/user/1000/.ydotool_socket";
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
