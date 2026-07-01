{
  pkgs,
  ...
}:
{
  services = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = false;
        package = pkgs.kdePackages.sddm;
        theme = "breeze";
        settings = {
          Input = {
            XkbLayout = "us,ru";
            XkbOptions = "grp:win_space_toggle";
          };
        };
      };
    };
    xserver = {
      enable = true;
      xkb = {
        layout = "us,ru";
        options = "grp:win_space_toggle";
      };
    };
  };
  console = {
    keyMap = "us";
  };
  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    plymouth.enable = true;
    kernelParams = [
      "quiet"
      "splash"
      "udev.log_level=3"
    ];
  };
}
