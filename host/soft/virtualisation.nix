{
  unstable-pkgs,
  inputs,
  ...
}:
{
  disabledModules = [
    "virtualisation/waydroid.nix"
  ];
  imports = [
    "${inputs.nixos-unstable}/nixos/modules/virtualisation/waydroid.nix"
  ];
  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    waydroid = {
      enable = true;
      package = unstable-pkgs.waydroid.override {
        withNftables = true;
      };
    };
  };
}
