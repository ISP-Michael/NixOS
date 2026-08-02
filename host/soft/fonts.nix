{
  pkgs,
  ...
}:
let
  nerdPkgs = with pkgs.nerd-fonts; [
    _0xproto
    caskaydia-cove
    caskaydia-mono
    comic-shanns-mono
    fira-code
    fira-mono
    hack
    iosevka
    jetbrains-mono
    monoid
    noto
    ubuntu
    ubuntu-mono
    ubuntu-sans
    victor-mono
  ];
in
{
  fonts = {
    enableDefaultPackages = true;
    fontconfig.enable = true;
    packages =
      nerdPkgs
      ++ (
        with pkgs; [
          alegreya-sans
          cascadia-code
          comic-mono
          fira-code
          hackgen-font
          hasklig
          noto-fonts
          noto-fonts-cjk-sans
          source-code-pro
        ]
      );
  };
}
