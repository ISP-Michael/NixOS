#!/usr/bin/env bash
# Поднимает PostgreSQL для портала «Конференции.РФ».
#
# Делает три вещи:
#   1. создаёт роль conf2027 — это пользователь в PostgreSQL, не в Linux
#   2. создаёт базу портала conf2027 — модули 1-3
#   3. применяет миграции Django и наполняет базу демо-данными
#
# Модуль 4 сюда не входит. Он вариативный, база для него выдаётся на
# экзамене, и разворачивается на месте.
#
# Запуск:  bash tools/pg_setup.sh
# Повторный запуск безопасен: роль и база не пересоздаются, пароль у
# роли выставляется заново, чтобы совпадать с кодом.
set -e
cd "$(dirname "$0")/.."

USER_NAME=conf2027
PASSWORD=conf2027
DB_NAME=conf2027

echo "1. Запускаю сервер PostgreSQL"
sudo systemctl enable --now postgresql

echo "2. Коллация кластера"
# После обновления glibc кластер, созданный при старой версии, перестаёт
# подходить шаблоном: CREATE DATABASE падает с «template database has a
# collation version mismatch». Лечится обновлением версии коллации.
for db in postgres template1; do
    if sudo -u postgres psql -d postgres -q \
            -c "ALTER DATABASE $db REFRESH COLLATION VERSION" 2>/dev/null; then
        echo "   $db: версия коллации в порядке"
    else
        echo "   ВНИМАНИЕ: $db — обновить версию коллации не вышло."
        echo "   Если база не создаётся, выполни вручную:"
        echo "   sudo -u postgres psql -d postgres \\"
        echo "     -c 'ALTER DATABASE $db REFRESH COLLATION VERSION'"
    fi
done

echo "3. Роль $USER_NAME"
if sudo -u postgres psql -tAc \
        "SELECT 1 FROM pg_roles WHERE rolname='$USER_NAME'" | grep -q 1; then
    echo "   роль уже есть, выставляю пароль заново"
    sudo -u postgres psql -q -c \
        "ALTER ROLE $USER_NAME WITH LOGIN PASSWORD '$PASSWORD' CREATEDB"
else
    echo "   создаю роль"
    sudo -u postgres psql -q -c \
        "CREATE ROLE $USER_NAME LOGIN PASSWORD '$PASSWORD' CREATEDB"
fi

echo "4. Создаю базу $DB_NAME"
if sudo -u postgres psql -tAc \
        "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1; then
    echo "   база уже есть, пропускаю"
else
    sudo -u postgres createdb -O "$USER_NAME" "$DB_NAME"
fi

echo "5. Миграции и демо-данные"
if [ -x .venv/bin/python ]; then
    PY=.venv/bin/python
else
    PY=python3
fi
if ! "$PY" -c "import psycopg" 2>/dev/null; then
    echo "   ОШИБКА: $PY не видит драйвер psycopg"
    echo "   Поставить:  $PY -m pip install 'psycopg[binary]'"
    exit 1
fi
"$PY" manage.py migrate --noinput
"$PY" manage.py seed

echo
echo "Готово. Проверка:"
echo "  PGPASSWORD=$PASSWORD psql -h 127.0.0.1 -U $USER_NAME -d $DB_NAME -c '\\dt main_*'"
echo "  .venv/bin/python manage.py runserver 8001"