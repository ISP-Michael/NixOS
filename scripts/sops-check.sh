#!/usr/bin/env bash
# Check that this machine can decrypt secrets/secrets.yaml. Never prints values.
set -euo pipefail
cd "$(dirname "$0")/.."

KEY="${SOPS_AGE_KEY_FILE:-/run/secrets-for-users.d/age-keys.txt}"
if [ ! -r "$KEY" ]; then
  echo "key not readable: $KEY" >&2
  echo "run as root or pass SOPS_AGE_KEY_FILE" >&2
  exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
  SOPS_AGE_KEY_FILE="$KEY" sops -d secrets/secrets.yaml >/dev/null
else
  SUDO_ASKPASS="${SUDO_ASKPASS:-$HOME/.local/state/opencode/askpass.sh}" \
    sudo -A env SOPS_AGE_KEY_FILE="$KEY" sops -d secrets/secrets.yaml >/dev/null
fi
echo "sops OK"
