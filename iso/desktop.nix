{
  config,
  pkgs,
  ...
}:
{
  programs = {
    hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      xwayland = {
        enable = true;
      };
    };
  };

  # Файловые диалоги на live-системе — GTK: он есть всегда, а KDE-портал
  # тянет за собой половину Plasma.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [
        "gtk"
      ];
    };
  };

  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          user = "greeter";
        };
        initial_session = {
          command = "${config.programs.hyprland.package}/bin/Hyprland";
          user = config.iso.user;
        };
      };
    };
  };

  environment = {
    sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_CURRENT_DESKTOP = "Hyprland";
    };
  };
}
