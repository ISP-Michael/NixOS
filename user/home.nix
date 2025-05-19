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
    username      = "Michael";
    stateVersion  = "25.05";
    homeDirectory = "/home/Michael";
    sessionVariables = {
      EDITOR = "nvim";
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
    ];
    file = {
      ".local/share/fonts/literata" = {
        source = ../dependencies/fonts/Literata;
        recursive = true;
      };
    };
  };
}
