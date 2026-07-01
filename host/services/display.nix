{
  pkgs,
  ...
}:
{
  services = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        theme = "sddm-astronaut-theme";
        extraPackages = with pkgs; [
          sddm-astronaut
          kdePackages.qtmultimedia
          kdePackages.qtsvg
        ];
      };
    };

    xserver = {
      enable = true;
      xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
      };
    };
  };

  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    plymouth.enable = true;
  };
}
