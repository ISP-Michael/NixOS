{
  systemd = {
    user = {
      services = {
        xdg-desktop-portal-hyprland = {
          serviceConfig = {
            Environment = [
              "QT_QPA_PLATFORMTHEME="
              "QT_STYLE_OVERRIDE="
              "R600_DEBUG=nodcc"
            ];
          };
        };
      };
    };
  };
}
