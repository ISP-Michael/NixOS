#!/usr/bin/env bash
# Host-side updater for the manual /opt/AmneziaVPN installation.
# ISO uses the pinned apps/amnezia/package.nix instead.
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "run as root: sudo $0" >&2; exit 1; }
export PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin:/usr/bin:/bin

API="https://api.github.com/repos/amnezia-vpn/amnezia-client/releases/latest"
LATEST="$(curl -fsSL --max-time 30 "$API" | jq -r '.tag_name')"
ASSET="$(curl -fsSL --max-time 30 "$API" | jq -r '.assets[] | select(.name | endswith("linux_x64.run")) | .browser_download_url' | head -1)"
[ -n "$LATEST" ] && [ -n "$ASSET" ] || { echo "latest asset not found" >&2; exit 1; }

TMP="$(mktemp -d /tmp/amnezia-update.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
echo "latest: $LATEST"
curl -fL --max-time 300 -o "$TMP/AmneziaVPN.run" "$ASSET"
sha256sum "$TMP/AmneziaVPN.run"

systemctl stop AmneziaVPN 2>/dev/null || true
BACKUP="/opt/AmneziaVPN.bak-$(date +%Y%m%d-%H%M%S)"
if [ -e /opt/AmneziaVPN ]; then
  mv /opt/AmneziaVPN "$BACKUP"
fi
mkdir -p /opt/AmneziaVPN

if ! QT_QPA_PLATFORM=offscreen HOME=/root \
  "$TMP/AmneziaVPN.run" \
  --root /opt/AmneziaVPN \
  --accept-licenses \
  --default-answer \
  --confirm-command install; then
  echo "install failed; rolling back" >&2
  rm -rf /opt/AmneziaVPN
  [ -d "$BACKUP" ] && mv "$BACKUP" /opt/AmneziaVPN
  systemctl start AmneziaVPN 2>/dev/null || true
  exit 1
fi

chmod -R a-w /opt/AmneziaVPN 2>/dev/null || true
systemctl start AmneziaVPN 2>/dev/null || true
echo "installed: $LATEST"
echo "backup:    $BACKUP"
echo "check:     systemctl status AmneziaVPN; ip -br addr; ip route"
