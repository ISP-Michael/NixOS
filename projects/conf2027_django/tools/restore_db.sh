#!/usr/bin/env bash
# Восстановление базы из последней резервной копии.
set -e
cd "$(dirname "$0")/.."
LAST=$(ls -t backups/db-*.sql 2>/dev/null | head -1)
if [ -z "$LAST" ]; then
    echo "Копий нет в папке backups/"
    exit 1
fi
echo "Восстанавливаю из $LAST"

export PGPASSWORD=conf2027
psql -h 127.0.0.1 -p 5432 -U conf2027 -d conf2027 -v ON_ERROR_STOP=1 -f "$LAST" > /dev/null

echo "Готово. Проверь: python manage.py shell -c \"from django.contrib.auth.models import User; print(User.objects.count())\""