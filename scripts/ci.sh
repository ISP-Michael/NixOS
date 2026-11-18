#!/usr/bin/env bash
# Fast, read-only checks for local use and CI.
# One nix eval evaluates all configurations/packages instead of 12 separate ones.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ "${ALLOW_DIRTY:-0}" != "1" ] && [ -n "$(git status --porcelain)" ]; then
  echo "working tree is dirty; commit/stage first or set ALLOW_DIRTY=1" >&2
  exit 1
fi

git diff --check

NIX_EXPR='
let
  flake = builtins.getFlake (toString /etc/nixos);
  configs = [
    "MagicBook"
    "MagicBookInstall"
    "iso-lite"
    "iso"
    "iso-custom"
    "iso-media"
    "iso-full"
  ];
  packages = [
    "iso-lite"
    "iso"
    "iso-custom"
    "iso-media"
    "iso-full"
  ];
  system = "x86_64-linux";
  configDrvs = map (name: {
    inherit name;
    drv = flake.nixosConfigurations.${name}.config.system.build.toplevel.drvPath;
  }) configs;
  packageOuts = map (name: {
    inherit name;
    out = flake.packages.${system}.${name}.outPath;
  }) packages;
in
builtins.deepSeq configDrvs (builtins.deepSeq packageOuts {
  configs = map (x: x.name) configDrvs;
  packages = map (x: x.name) packageOuts;
})
'

OUT="$(nix eval --impure --json --expr "$NIX_EXPR")"
echo "$OUT" | jq -r '.configs[] | "OK config \(.)"'
echo "$OUT" | jq -r '.packages[] | "OK package \(.)"'
echo "all checks passed"
