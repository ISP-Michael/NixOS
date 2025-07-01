{ pkgs, ... }:
{
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      alegreya-sans
      corefonts
      hasklig
      source-code-pro
      nerd-fonts._0xproto
      nerd-fonts.caskaydia-cove
      nerd-fonts.caskaydia-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono
      nerd-fonts.monoid
      nerd-fonts.noto
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      nerd-fonts.victor-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      texlivePackages.alegreya
    ];
  };
}
