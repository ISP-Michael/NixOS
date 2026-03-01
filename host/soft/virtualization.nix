{
  unstable-pkgs,
  ...
}:
{
  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;

    waydroid = {
      enable = true;
      package = unstable-pkgs.waydroid;
    };
  };
}
