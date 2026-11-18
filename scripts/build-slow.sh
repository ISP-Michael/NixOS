#!/usr/bin/env bash
# Run a heavy build in a low-impact cgroup: one core, idle I/O, memory cap.
# Usage: ./scripts/build-slow.sh nix build .#... --max-jobs 1 --cores 1
set -euo pipefail
cd "$(dirname "$0")/.."

CPU_QUOTA="${CPU_QUOTA:-80%}"
MEM_HIGH="${MEM_HIGH:-4G}"
MEM_MAX="${MEM_MAX:-5G}"

if command -v ionice >/dev/null 2>&1; then
  exec systemd-run --user --scope --collect --nice=19 \
    -p "CPUQuota=${CPU_QUOTA}" \
    -p "MemoryHigh=${MEM_HIGH}" \
    -p "MemoryMax=${MEM_MAX}" \
    -- ionice -c 3 "$@"
else
  exec systemd-run --user --scope --collect --nice=19 \
    -p "CPUQuota=${CPU_QUOTA}" \
    -p "MemoryHigh=${MEM_HIGH}" \
    -p "MemoryMax=${MEM_MAX}" \
    -- "$@"
fi
