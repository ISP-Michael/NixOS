{
  pkgs,
  ...
}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "amnezia-vpn-run";
  version = "5.1.0.6";

  src = pkgs.fetchurl {
    url = "https://github.com/amnezia-vpn/amnezia-client/releases/download/5.1.0.6/AmneziaVPN_5.1.0.6_linux_x64.run";
    hash = "sha256-9gpPNzMy2shGW9m45PIz7jqjITH+Ek0xynC8SZxzSW8=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/share/amnezia-vpn/AmneziaVPN.run
    runHook postInstall
  '';

  meta = {
    description = "AmneziaVPN 5.1.0.6 installer (run at activation)";
    homepage = "https://amnezia.org";
    platforms = [ "x86_64-linux" ];
  };
}
