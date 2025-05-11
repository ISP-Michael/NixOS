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
    file = {};
    username      = "Michael";
    stateVersion  = "25.05";
    homeDirectory = "/home/Michael";
    sessionVariables = {
      EDITOR = "nvim";
    };
    packages = [
      pythonEnv13
    ];
  };
}
