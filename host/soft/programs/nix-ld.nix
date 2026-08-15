{
  pkgs,
  lib,
  ...
}:
{
  system.activationScripts.nix-ld-bin-bash = lib.mkAfter ''
    ln -sfn ${pkgs.bash}/bin/bash /bin/bash
  '';
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        brotli.lib
        dbus.lib
        fontconfig.lib
        freetype
        glib
        krb5.lib
        libfontenc
        libxkbcommon
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
