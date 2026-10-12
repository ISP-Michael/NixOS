#!/usr/bin/env bash
# Резервная копия базы портала.
# Запускай ПЕРЕД любыми опасными действиями: удалением базы, migrate,
# массовой правкой моделей. Данные пользователей невосстановимы.
set -e
cd "$(dirname "$0")/.."
mkdir -p backups
STAMP=$(date +%Y%m%d-%H%M%S)
OUT="backups/db-$STAMP.sql"

export PGPASSWORD=conf2027
pg_dump -h 127.0.0.1 -p 5432 -U conf2027 -d conf2027 --clean --if-exists -f "$OUT"

echo "Копия сохранена: $OUT"