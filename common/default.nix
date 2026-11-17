{
  imports = [
    ./audio/pipewire.nix
    ./desktop/session.nix
    ./hardware/bluetooth.nix
    ./hardware/mtp.nix
    ./nix/cache.nix
    ./nix/experimental-features.nix
    ./programs/appimage.nix
    ./programs/dconf.nix
    ./programs/nix-ld.nix
    ./programs/zsh.nix
    ./services/base.nix
    ./system/environment.nix
    ./system/locale.nix
    ./system/time.nix
  ];
}
