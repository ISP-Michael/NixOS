# Один eval на все конфигурации вместо 12 отдельных запусков.
#
# quick — повседневная проверка: хост и iso-custom.
# full  — всё, что нужно перед пушем: 7 конфигураций и 5 ISO-пакетов.
{ mode ? "full" }:
let
  flake = builtins.getFlake (toString /etc/nixos);
  system = "x86_64-linux";
  quick = mode == "quick";

  configs =
    if quick then
      [
        "MagicBook"
        "iso-custom"
      ]
    else
      [
        "MagicBook"
        "MagicBookInstall"
        "iso-lite"
        "iso"
        "iso-custom"
        "iso-media"
        "iso-full"
      ];

  packages =
    if quick then
      [
        "iso-custom"
      ]
    else
      [
        "iso-lite"
        "iso"
        "iso-custom"
        "iso-media"
        "iso-full"
      ];

  configDrvs = map (name: {
    inherit name;
    drv = flake.nixosConfigurations.${name}.config.system.build.toplevel.drvPath;
  }) configs;

  packageOuts = map (name: {
    inherit name;
    out = flake.packages.${system}.${name}.outPath;
  }) packages;
in
builtins.deepSeq configDrvs (
  builtins.deepSeq packageOuts {
    configs = map (x: x.name) configDrvs;
    packages = map (x: x.name) packageOuts;
  }
)
