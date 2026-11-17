{
  pkgs,
  inputs,
  system,
  ...
}:
let
  zen = inputs.zen-browser.packages.${system}.default;
  freesmlauncher = inputs.freesmlauncher.packages.${system}.freesmlauncher;

  # nixpkgs 26.11.20261020: pywal16 задаёт makeWrapperArgs одной строкой, а новый
  # make-shell-wrapper читает аргументы по одному и падает с
  # "makeWrapper doesn't understand the arg --prefix PATH : ...". Разбиваем на элементы.
  pywal16 = pkgs.pywal16.overrideAttrs (
    _: {
      makeWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        (
          pkgs.lib.makeBinPath [
            pkgs.imagemagick
          ]
        )
      ];
    }
  );

  # Telegram: KDE platform theme даёт и цвета, и нативный файловый диалог.
  telegram-portal = pkgs.runCommand "telegram-desktop-kde" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin $out/share
    makeWrapper ${pkgs.telegram-desktop}/bin/Telegram $out/bin/Telegram \
      --set QT_QPA_PLATFORMTHEME kde
    for d in applications icons metainfo; do
      ln -s ${pkgs.telegram-desktop}/share/$d $out/share/$d
    done
    mkdir -p $out/share/dbus-1/services
    sed "s|${pkgs.telegram-desktop}/bin/Telegram|$out/bin/Telegram|" \
      ${pkgs.telegram-desktop}/share/dbus-1/services/org.telegram.desktop.service \
      > $out/share/dbus-1/services/org.telegram.desktop.service
  '';

  neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.default;

  # Ночной Neovide: стабильный 0.16.2 не разбирает api-info от nvim-nightly
  # (новое поле `optional`, фикс только в main — PR #3530), поэтому берём
  # бинарник из rolling-релиза `nightly` (asset от 2026-10-16, коммит 19c705370fda).
  # При обновлении апстрима хеш и version брать так:
  #   nix store prefetch-file --json --hash-type sha256 <URL ниже>
  neovide-nightly = pkgs.stdenvNoCC.mkDerivation {
    pname = "neovide";
    version = "nightly-g19c7053";
    src = pkgs.fetchurl {
      url = "https://github.com/neovide/neovide/releases/download/nightly/neovide-linux-x86_64.tar.gz";
      hash = "sha256-FQhFmrYxGChq1MXU50KviSoMr5D/MlBEQ630A2FEu4U=";
    };
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];
    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.fontconfig
    ];
    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      install -Dm755 neovide $out/bin/neovide
      install -Dm644 ${pkgs.neovide}/share/applications/neovide.desktop \
        $out/share/applications/neovide.desktop
      mkdir -p $out/share/icons/hicolor
      cp -a ${pkgs.neovide}/share/icons/hicolor/. $out/share/icons/hicolor/
    '';
    postFixup = ''
      wrapProgram $out/bin/neovide \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
          pkgs.libglvnd
          pkgs.libxkbcommon
          pkgs.libx11
          pkgs.libxcursor
          pkgs.libxext
          pkgs.libxrandr
          pkgs.libxi
          pkgs.wayland
        ]}
    '';
    meta.mainProgram = "neovide";
  };
in
{
  home = {
    packages = [
      zen
      freesmlauncher
      pywal16
      telegram-portal
      neovim-nightly
      neovide-nightly
    ];
  };
}
