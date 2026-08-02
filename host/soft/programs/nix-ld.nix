{
  pkgs,
  ...
}:
{
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        libfontenc
        libGL
        libice
        libsm
        libx11
        libxau
        libxaw
        libxcb
        libxcb-cursor
        libxcb-image
        libxcb-keysyms
        libxcb-render-util
        libxcb-util
        libxcb-wm
        libxcomposite
        libxcursor
        libxdamage
        libxdmcp
        libxext
        libxfixes
        libxi
        libxinerama
        libxkbfile
        libxmu
        libxpm
        libxrandr
        libxrender
        libxres
        libxscrnsaver
        libxt
        libxtst
        libxv
        libxxf86vm
        stdenv.cc.cc.lib
      ];
    };
  };
}
