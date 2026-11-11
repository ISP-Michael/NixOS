#!/usr/bin/env bash
# Снимает зашифрованный снимок живых файлов OpenClaw/OpenCode в
# /etc/nixos/secrets/apps.yaml (sops). Секреты не печатаются.
# Живые файлы — источник истины; снимок опционален.
set -euo pipefail

ROOT="${ROOT:-/etc/nixos}"
OUT="$ROOT/secrets/apps.yaml"
umask 077

OLD_TOKEN="REPLACE_ME"
if [ -f "$OUT" ]; then
  cp -a "$OUT" "$OUT.bak"
  if val=$(sops --config "$ROOT/.sops.yaml" -d --extract '["telegram-bot-token"]' "$OUT" 2>/dev/null); then
    [ -n "$val" ] && OLD_TOKEN="$val"
  fi
fi
export OLD_TOKEN

trap 'rm -f "$OUT"' ERR

python3 - "$OUT" <<'PY'
import json
import os
import pathlib
import sys

out = pathlib.Path(sys.argv[1])
home = pathlib.Path.home()


def read(p):
    try:
        return p.read_text().strip()
    except Exception:
        return None


def block(text):
    return "\n".join("  " + line for line in text.splitlines())


parts = []
oc = read(home / ".openclaw/openclaw.json")
if oc:
    parts.append("openclaw-json: |\n" + block(oc))

auth = read(home / ".local/share/opencode/auth.json")
if auth:
    parts.append("opencode-auth-json: |\n" + block(auth))

svc = read(home / ".local/state/opencode/service.json")
if svc:
    try:
        pw = json.loads(svc).get("password", "")
    except Exception:
        pw = ""
    if pw:
        parts.append("opencode-service-password: " + json.dumps(pw, ensure_ascii=False))

parts.append("telegram-bot-token: " + json.dumps(os.environ.get("OLD_TOKEN", "REPLACE_ME")))
out.write_text("\n".join(parts) + "\n")
os.chmod(out, 0o600)
PY

if ! sops --config "$ROOT/.sops.yaml" -e -i "$OUT"; then
  rm -f "$OUT"
  echo "sops encrypt failed; plaintext removed" >&2
  exit 1
fi
trap - ERR
chmod 600 "$OUT"
echo "encrypted: $OUT"
