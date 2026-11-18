#!/usr/bin/env bash
# Host-side updater for the manual /opt/happ installation.
# ISO uses vendor/happ/module.nix with a pinned package instead.
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "run as root: sudo $0" >&2; exit 1; }
export PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin:/usr/bin:/bin

API="https://api.github.com/repos/Happ-proxy/happ-desktop/releases/latest"
LATEST="$(curl -fsSL --max-time 30 "$API" | jq -r '.tag_name')"
ASSET="$(curl -fsSL --max-time 30 "$API" | jq -r '.assets[] | select(.name | endswith("linux.x64.deb")) | .browser_download_url' | head -1)"
[ -n "$LATEST" ] && [ -n "$ASSET" ] || { echo "latest .deb not found" >&2; exit 1; }

TMP="$(mktemp -d /tmp/happ-update.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
echo "latest: $LATEST"
curl -fL --max-time 300 -o "$TMP/happ.deb" "$ASSET"
sha256sum "$TMP/happ.deb"
dpkg-deb -x "$TMP/happ.deb" "$TMP/root"

SRC="$(find "$TMP/root" -maxdepth 4 -type f -name happd -printf '%h\n' | head -1)"
[ -n "$SRC" ] || { echo "happd not found in .deb" >&2; exit 1; }
SRC="$(dirname "$SRC")" # .../opt/happ/bin -> .../opt/happ
[ -x "$SRC/bin/happd" ] || SRC="$(dirname "$SRC")"

systemctl stop happd 2>/dev/null || true
BACKUP="/opt/happ.bak-$(date +%Y%m%d-%H%M%S)"
if [ -e /opt/happ ]; then
  mv /opt/happ "$BACKUP"
fi
mkdir -p /opt/happ
cp -a "$SRC/." /opt/happ/
chown -R root:root /opt/happ
chmod -R u=rwX,go=rX /opt/happ

if ! systemctl start happd; then
  echo "happd failed; rolling back" >&2
  rm -rf /opt/happ
  [ -d "$BACKUP" ] && mv "$BACKUP" /opt/happ
  systemctl start happd 2>/dev/null || true
  exit 1
fi

echo "installed: $LATEST"
echo "backup:    $BACKUP"
echo "check:     systemctl status happd; command -v happ; ip -br addr"
