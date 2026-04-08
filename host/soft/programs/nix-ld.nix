{
  unstable-pkgs,
  ...
}:
{
  programs = {
    nix-ld = {
      enable = true;
      libraries = with unstable-pkgs; [
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
