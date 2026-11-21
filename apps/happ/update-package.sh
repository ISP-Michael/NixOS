#!/usr/bin/env bash
# Check or update the pinned Happ package used by the live ISO.
# The host /opt install is updated separately by update.sh.
set -euo pipefail

cd "$(dirname "$0")/../.."
PKG="apps/happ/package.nix"
API="https://api.github.com/repos/Happ-proxy/happ-desktop/releases/latest"

current="$(sed -n 's/^[[:space:]]*version = "\(.*\)";/\1/p' "$PKG" | head -1)"
[ -n "$current" ] || { echo "cannot read version from $PKG" >&2; exit 1; }

release="$(curl -fsSL --max-time 30 "$API")"
latest="$(jq -r '.tag_name' <<<"$release" | sed 's/^v//')"
asset="$(jq -r '.assets[] | select(.name | endswith("linux.x64.deb")) | .browser_download_url' <<<"$release" | head -1)"
[ -n "$latest" ] && [ "$latest" != "null" ] || { echo "latest release not found" >&2; exit 1; }

echo "current: $current"
echo "latest:  $latest"

if [ "$latest" = "$current" ]; then
  echo "up to date"
  exit 0
fi

if [ "${1:-}" != "--update" ]; then
  echo "update available: run $0 --update"
  exit 0
fi

[ -n "$asset" ] && [ "$asset" != "null" ] || { echo "latest .deb asset not found" >&2; exit 1; }

tmp="$(mktemp -d /tmp/happ-package.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT
curl -fL --max-time 300 -o "$tmp/happ.deb" "$asset"
hash="$(nix hash file --type sha256 --sri "$tmp/happ.deb")"

cp -a "$PKG" "$PKG.bak-update"
sed -i "s/version = \"$current\"/version = \"$latest\"/" "$PKG"
sed -i "s|sha256 = \"sha256-[^\"]*\"|sha256 = \"$hash\"|" "$PKG"

echo "package.nix: $current -> $latest"
echo "sha256: $hash"

if ! nix build .#happ --no-link; then
  echo "build failed; restoring $PKG" >&2
  mv "$PKG.bak-update" "$PKG"
  exit 1
fi

rm -f "$PKG.bak-update"
echo "built .#happ successfully"
echo "next: inspect new dependencies, build .#iso-custom, smoke-test Happ"
