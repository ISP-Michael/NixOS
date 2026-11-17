{
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "opencode";
  version = "2.3.0";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-2.3.0.tgz";
    hash = "sha512-8T3K8L6Nd4fSG5BSgofqhmIDQ1ZvzDZZ2J7bFVB9RK1d5Hjqh24IcxgbcwpgGKkdvItrayi4Rl+wrSmhl17FFg==";
  };

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
  ];

  buildInputs = [
    pkgs.glibc
    pkgs.stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/opencode $out/bin/opencode
    runHook postInstall
  '';

  meta = {
    description = "OpenCode 2 coding agent";
    homepage = "https://opencode.ai";
    mainProgram = "opencode";
    platforms = [ "x86_64-linux" ];
  };
}
