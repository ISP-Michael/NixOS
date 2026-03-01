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
    iosevka
    jetbrains-mono
    monoid
    noto
    ubuntu
    ubuntu-mono
    ubuntu-sans
    victor-mono
    hack
  ];
in
{
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
    };
    packages =
      nerdPkgs ++
      (with pkgs; [
        alegreya-sans
        corefonts
        comic-mono
        fira-code
        hasklig
        noto-fonts
        noto-fonts-cjk-sans
        source-code-pro
        hackgen-font
      ]);
  };
}
