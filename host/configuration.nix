{
  imports = [
    ./boot.nix
    ./console.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./scripts
    ./services
    ./settings
    ./soft
    ./system
    ./time.nix
    ./users
  ];

  documentation = {
    man = {
      generateCaches = false;
    };
  };

  systemd = {
    user = {
      services = {
        xdg-desktop-portal-hyprland = {
          serviceConfig = {
            Environment = [
              "QT_QPA_PLATFORMTHEME="
              "QT_STYLE_OVERRIDE="
            ];
          };
        };
      };
    };
  };
}
