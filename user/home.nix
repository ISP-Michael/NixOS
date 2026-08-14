{
  pkgs,
  lib,
  ...
}:
{
  home = {
    username = "Michael";
    stateVersion = "26.05";
    homeDirectory = "/home/Michael";
    pointerCursor.enable = true;
    sessionVariables = {
      BROWSER = "zen";
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      VISUAL = "nvim";
    };
    packages = with pkgs; [
      glib
      gtk3
    ];
  };
  xdg = {
    mime.sharedMimeInfoPackage = lib.hiPrio pkgs.shared-mime-info;
    configFile = {
      "environment.d/10-openclaw.conf".text = ''
        OPENCLAW_NIX_MODE=0
        OPENCLAW_DISABLE_PERSISTED_PLUGIN_REGISTRY=0
      '';
    };
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
