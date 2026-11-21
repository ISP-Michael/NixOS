#!/usr/bin/env bash
# Read-only checks for local use and CI.
#
# Two modes:
#   --quick  host + iso-custom, для повседневной работы;
#   (none)   все конфигурации и ISO-пакеты, перед пушем.
#
# The eval runs in a transient systemd scope with a memory cap, so a heavy
# flake evaluation cannot push the desktop into swap. On CI (no user systemd)
# it falls back to a plain eval.
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/guard-gaming.sh

MODE="full"
case "${1:-}" in
  --quick)
    MODE="quick"
    ;;
  "")
    ;;
  *)
    echo "usage: $0 [--quick]" >&2
    exit 2
    ;;
esac

if [ "${ALLOW_DIRTY:-0}" != "1" ] && [ -n "$(git status --porcelain)" ]; then
  echo "working tree is dirty; commit/stage first or set ALLOW_DIRTY=1" >&2
  exit 1
fi

git diff --check

if [ "$MODE" = "quick" ]; then
  MEMORY_HIGH="2G"
  MEMORY_MAX="3G"
  MEMORY_SWAP_MAX="512M"
else
  MEMORY_HIGH="3G"
  MEMORY_MAX="4G"
  MEMORY_SWAP_MAX="1G"
fi

run_eval() {
  if command -v systemd-run >/dev/null 2>&1 && systemctl --user show-environment >/dev/null 2>&1; then
    systemd-run --user --scope --quiet \
      -p "MemoryHigh=${MEMORY_HIGH}" \
      -p "MemoryMax=${MEMORY_MAX}" \
      -p "MemorySwapMax=${MEMORY_SWAP_MAX}" \
      -- nix eval --impure --json --file scripts/ci-eval.nix \
      --apply "f: f { mode = \"${MODE}\"; }"
  else
    nix eval --impure --json --file scripts/ci-eval.nix \
      --apply "f: f { mode = \"${MODE}\"; }"
  fi
}

if ! OUT="$(run_eval)"; then
  echo "nix eval failed; if it hit the ${MEMORY_MAX} cgroup limit, close heavy apps or use 'make check'" >&2
  exit 1
fi

echo "$OUT" | jq -r '.configs[] | "OK config \(.)"'
echo "$OUT" | jq -r '.packages[] | "OK package \(.)"'

./scripts/hypr-check.sh
./scripts/zsh-check.sh
./scripts/nvim-check.sh

echo "all checks passed"
