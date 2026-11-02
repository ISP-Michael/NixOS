{
  imports = [ ../../happ-nixos/happ-module.nix ];

  services.happ = {
    enable = true;
    # Hyprland is wlroots-based: Happ's bundled Qt6 Wayland plugins crash
    # silently there, so run it through XWayland (see happ-nixos/README.md).
    forceXwayland = true;
  };
}
