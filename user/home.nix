{ pkgs, ... }:
let
  pythonEnv13 = pkgs.python313.withPackages(
    ps: with ps; [
      nox
      numpy
      django
      pandas
      cython
      nuitka
      fastapi
      requests
      fastapi-cli
    ]
  );
in
{
  home = {
    username = "Michael";
    stateVersion = "25.11";
    homeDirectory = "/home/Michael";
    sessionVariables = {
      EDITOR = "nvim";
      NIXOS_OZONE_WL = "1";
      KDE_NO_OPENGL_WINDOW_DECORATION = "1";
      QT_WAYLAND_DISABLE_WINDOW_DECORATION = "1";
    };
    packages = with pkgs; [
      imv
      mpv
      neovim
      nautilus
      obsidian
      xfce.thunar
      pythonEnv13
      telegram-desktop
      libsForQt5.qtstyleplugins
    ];
    file = {
      ".local/share/fonts/literata" = {
        source = ../dependencies/fonts/Literata;
        recursive = true;
      };
    };
  };
}
