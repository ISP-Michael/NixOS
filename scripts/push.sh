#!/usr/bin/env bash
# Commit/push helper: checks first, then pushes to all URLs configured for origin.
set -euo pipefail
cd "$(dirname "$0")/.."

# Локально — только быстрая проверка; полный прогон делает GitHub Actions.
./scripts/ci.sh
git push origin main
