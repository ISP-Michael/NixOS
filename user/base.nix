{
  pkgs,
  identity,
  ...
}:
{
  home = {
    username = identity.user;
    stateVersion = "26.05";
    homeDirectory = identity.home;
    sessionVariables = {
      BROWSER = "zen";
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      VISUAL = "nvim";
      WGET_HSTS_FILE = "$HOME/.local/share/wget/hsts";
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
