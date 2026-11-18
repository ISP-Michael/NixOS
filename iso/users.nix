{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.iso.user = lib.mkOption {
    type = lib.types.str;
    default = "Michael";
    description = "Пользователь live-системы.";
  };

  config = {
    users = {
      users = {
        ${config.iso.user} = {
          isNormalUser = true;
          home = "/home/${config.iso.user}";
          shell = pkgs.zsh;
          initialHashedPassword = "";
          extraGroups = [
            "wheel"
            "networkmanager"
            "video"
            "audio"
            "input"
            "render"
            "bluetooth"
          ];
        };
      };
    };

    security = {
      sudo = {
        wheelNeedsPassword = lib.mkForce false;
      };
    };

    services = {
      getty = {
        # greetd сам стартует Hyprland, getty на tty1 только мешает.
        autologinUser = lib.mkForce null;
        helpLine = lib.mkForce "";
      };
    };
  };
}
