{ pkgs, ... }:
{
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      hasklig
      corefonts
      noto-fonts
      alegreya-sans
      nerd-fonts.noto
      noto-fonts-emoji
      nerd-fonts.ubuntu
      nerd-fonts.iosevka
      noto-fonts-cjk-sans
      nerd-fonts._0xproto
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      nerd-fonts.victor-mono
      texlivePackages.alegreya
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.caskaydia-mono
    ];
  };
}
