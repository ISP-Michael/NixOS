{
  pkgs,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      git
      neovim
      rsync
      parted
      gptfdisk
      nixos-install-tools
    ];
  };
}
