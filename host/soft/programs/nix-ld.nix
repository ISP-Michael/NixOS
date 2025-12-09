{
  unstable-pkgs,
  lib,
  ...
}:
let
  allQt5Libs = lib.filter
    (pkg: let eval = builtins.tryEval (lib.isDerivation pkg); in eval.success && eval.value)
    (lib.attrValues unstable-pkgs.libsForQt5.qt5);
  baseQt5Libs = with unstable-pkgs.libsForQt5.qt5; [
    qtbase
    qtdeclarative
  ];
in
{
  programs = {
    nix-ld = {
      enable = true;
      libraries = with unstable-pkgs; baseQt5Libs ++ [
        libGL
        libice
        libsm
        libxau
        libxaw
        libxdamage
        libxdmcp
        libxext
        libxv
        libxkbfile
        libxtst
        libxt
        libxfixes
        libx11
        libxcb
        libxcb-cursor
        libxcb-image
        libxcb-keysyms
        libxcb-render-util
        libxcb-util
        libxcb-wm
        libxcomposite
        libxcursor
        libxinerama
        libxi
        libxrandr
        libxres
        libxrender
        libxpm
        libxmu
        libxscrnsaver
        libxxf86vm
        libfontenc
        stdenv.cc.cc.lib
      ];
    };
  };
}
