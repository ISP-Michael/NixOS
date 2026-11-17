{
  pkgs,
  config,
  ...
}:
let
  python13Env = pkgs.python313.withPackages (
    ps:
      with ps; [
        aiogram
        cython
        debugpy
        django
        fastapi
        fastapi-cli
        grip
        matplotlib
        (pkgs.lib.hiPrio nox)
        nuitka
        numpy
        pandas
        pillow
        psutil
        requests
        rich
      ]
  );

  python314Env = pkgs.python314.withPackages (
    ps:
      with ps; [
        fastembed
        numpy
      ]
  );

  sessionSemantic = pkgs.writeShellScriptBin "session-semantic" ''
    exec ${python314Env}/bin/python3.14 ${config.home.homeDirectory}/.openclaw/workspace/scripts/session-semantic.py "$@"
  '';
in
{
  home = {
    packages = [
      python13Env
      sessionSemantic
    ];
  };
}
