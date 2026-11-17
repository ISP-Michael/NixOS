{
  lib,
  pkgs,
  self,
  ...
}:
let
  # Исходники флейка без истории git и без локальных тяжёлых каталогов.
  # Такой репозиторий можно читать и собирать прямо из live-системы,
  # а после установки — скопировать на диск и продолжать уже там.
  repo = pkgs.runCommand "nixos-config-iso" { } ''
    mkdir -p $out
    cp -a ${self}/. $out/
    chmod -R u+w $out
    rm -rf $out/.git
    rm -rf $out/result $out/result-*
    rm -rf $out/secrets/opencode-restic
    # Зашифрованный снимок живых токенов и тяжёлые видео в live-системе
    # не нужны; в git их может не быть, но подстраховка дешёвая.
    rm -rf $out/secrets/apps.yaml
    rm -rf $out/assets/videos
  '';
in
{
  # installation-device создаёт /etc/nixos/configuration.nix-заглушку,
  # нам нужен настоящий флейк, поэтому заглушку отключаем.
  installer.cloneConfig = lib.mkForce false;

  system.activationScripts.isoRepo = ''
    if [ ! -e /etc/nixos/flake.nix ]; then
      mkdir -p /etc/nixos
      cp -a ${repo}/. /etc/nixos/
      chmod -R u+w /etc/nixos
    fi
  '';
}
