#!/usr/bin/env bash
# Host-side updater for the manual /opt/Throne installation.
# ISO does not include Throne; Happ is used there.
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "run as root: sudo $0" >&2; exit 1; }
export PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin:/usr/bin:/bin

API="https://api.github.com/repos/throneproj/Throne/releases/latest"
LATEST="$(curl -fsSL --max-time 30 "$API" | jq -r '.tag_name')"
ASSET="$(curl -fsSL --max-time 30 "$API" | jq -r '.assets[] | select(.name | endswith("linux-amd64.zip")) | .browser_download_url' | head -1)"
[ -n "$LATEST" ] && [ -n "$ASSET" ] || { echo "latest linux-amd64.zip not found" >&2; exit 1; }

TMP="$(mktemp -d /tmp/throne-update.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
echo "latest: $LATEST"
curl -fL --max-time 300 -o "$TMP/throne.zip" "$ASSET"
sha256sum "$TMP/throne.zip"
unzip -q "$TMP/throne.zip" -d "$TMP/root"

SRC="$(find "$TMP/root" -maxdepth 3 -type f -name Throne -printf '%h\n' | head -1)"
[ -n "$SRC" ] || { echo "Throne binary not found in zip" >&2; exit 1; }

BACKUP="/opt/Throne.bak-$(date +%Y%m%d-%H%M%S)"
if [ -e /opt/Throne ]; then
  mv /opt/Throne "$BACKUP"
fi
mkdir -p /opt/Throne
cp -a "$SRC/." /opt/Throne/
chown -R root:root /opt/Throne
chmod -R u=rwX,go=rX /opt/Throne
[ -e /opt/Throne/ThroneCore ] && chmod u+s /opt/Throne/ThroneCore

echo "installed: $LATEST"
echo "backup:    $BACKUP"
echo "check:     command -v throne; ls -l /opt/Throne/ThroneCore"
