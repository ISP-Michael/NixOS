# Пошаговая инструкция: портал «Конференции.РФ»
Специальность 09.02.07. Демонстрационный экзамен, модули 1–4.
Инструкция собрана скриптом `tools/docgen.py` из настоящих файлов
проекта, поэтому код в ней не может разойтись с кодом. Правь
проект, потом запускай скрипт заново.

## 0. С чего начать читать

Документа два, и они отвечают на разные вопросы.

| Документ | Вопрос, на который отвечает |
|---|---|
| `KAK_ETO_RABOTAET.md` | Почему всё устроено именно так. Что Django
  делает сам, что пишешь ты, как из текста задания получаются
  таблицы и страницы |
| `INSTRUKCIYA.md` (этот файл) | Что конкретно напечатать, в каком
  порядке и на что не наступить |

Читай `KAK_ETO_RABOTAET.md` первым, целиком, один раз. Потом
вернись сюда и собирай проект по шагам.

## 1. Что это за проект

Портал бронирования помещений для конференций. Четыре модуля
экзамена закрываются одним проектом:

| Модуль | Что закрывает | Где в проекте |
|---|---|---|
| 1. Регистрация, вход, заявки, панель администратора | задания 1.1–1.6 | `main/` |
| 2. Дизайн веб-приложений | задание 2.1 | `mobile/` |
| 3. Адаптив, CRUD, фреймворки, HTML5, анимации, ER-схема | задания 3.1–3.7 | `main/`, `static/`, `docs/` |
| 4. API заказов из `shop_db.sql` | задание 4.1 | `api.py` |

Две отдельные программы, общий код между ними не нужен и не
делается:

| Программа | Порт | Что это |
|---|---|---|
| Портал | 8001 | Django, модули 1–3 |
| API | 8081 | чистая стандартная библиотека Python, модуль 4 |

Задание 4.1 требует порт `localhost:8080`. Если в поле «Порт
приложения» проверяющей системы указать 8081, подойдёт любой
свободный порт. Поэтому 8001 и 8081 — чтобы не столкнуться с
чем-то занятым на чужой машине.

## 2. Порядок сборки

Собирать надо строго сверху вниз. Каждый шаг даёт работающий
результат, который можно открыть в браузере и посмотреть.

| Шаг | Что появится | Раздел |
|---|---|---|
| 1 | Папка проекта, Django и драйвер установлены | [4](#4-подготовка-машины) |
| 2 | PostgreSQL поднят, роль и база созданы | [5](#5-postgresql-что-это-и-как-поднять) |
| 3 | Пустой Django-проект `portal` | [6](#6-создание-проекта) |
| 4 | Настройки, база подключена | [7](#7-настройки) |
| 5 | Две таблицы описаны в моделях | [8](#8-таблицы) |
| 6 | Таблицы появились в базе | [9](#9-миграции) |
| 7 | Проверка форматов полей | [10](#10-проверка-форматов-полей) |
| 8 | Формы с `data-testid` | [11](#11-формы) |
| 9 | Все 7 представлений | [12](#12-представления) |
| 10 | Адреса работают | [13](#13-адреса) |
| 11 | Страницы выглядят как сайт | [14](#14-шаблоны) |
| 12 | Стили, адаптивность, анимация | [15](#15-вёрстка-адаптивность-и-анимация) |
| 13 | Демонстрационные данные | [16](#16-начальные-данные) |
| 14 | Макеты 390×844 | [17](#17-макеты-модуль-2) |
| 15 | API заказов — вариативный модуль, может не понадобиться | [18](#18-модуль-4-api-заказов) |
| 16 | Проверка перед сдачей | [19](#19-проверка-перед-сдачей) |
| 17 | Три архива | [20](#20-три-архива) |

На экзамене 4 часа. Ориентир по времени —
[раздел 21](#21-тайминг-на-4-часа).

## 3. Карта файлов

Всё, что нужно сдать, и всё, что нужно создать с нуля.
Число строк посчитано из настоящих файлов, таблица не
расходится с проектом.

**В репозитории и в архиве:**

| Файл | Строк | Зачем |
|---|---|---|
| `manage.py` | 19 | Django создаёт сам |
| `portal/settings.py` | 63 | настройки проекта |
| `portal/urls.py` | 7 | корневой список адресов |
| `portal/wsgi.py` | 7 | Django создаёт сам |
| `portal/asgi.py` | 7 | Django создаёт сам |
| `main/models.py` | 48 | две таблицы |
| `main/views.py` | 134 | семь представлений |
| `main/forms.py` | 99 | четыре формы |
| `main/validators.py` | 16 | форматы полей из задания |
| `main/urls.py` | 13 | семь адресов |
| `main/apps.py` | 5 | Django создаёт сам |
| `main/management/commands/seed.py` | 42 | демонстрационные данные |
| `main/migrations/0001_initial.py` | 101 | создаётся командой `makemigrations` |
| `templates/base.html` | 54 | общий каркас: шапка, меню, подвал |
| `templates/form_fields.html` | 12 | общий кусок всех форм |
| `templates/register.html` | 20 | страница регистрации |
| `templates/login.html` | 16 | страница входа |
| `templates/application_new.html` | 15 | форма новой заявки |
| `templates/applications.html` | 98 | список заявок, отзывы, CRUD |
| `templates/admin.html` | 61 | панель администратора |
| `static/style.css` | 221 | весь вид сайта |
| `static/app.js` | 15 | подтверждение смены статуса |
| `mobile/*` | 380 | 5 макетов под 390×844 |
| `api.py` | 139 | модуль 4, без Django |
| `tools/check_autotest.py` | 282 | 46 сквозных проверок |
| `tools/pg_setup.sh` | 77 | поднимает базу одной командой |
| `tools/backup_db.sh` | 13 | копия базы через pg_dump |
| `tools/restore_db.sh` | 14 | откат базы из копии |
| `tools/docgen.py` | 1445 | генератор этой инструкции |

Не считаются строками, но нужны:

| Файл | Зачем |
|---|---|
| `static/fonts/*.ttf` | PT Sans из Прил_1 |
| `static/img/*.jpg` | картинка на странице регистрации |
| `docs/ER-diagramma.svg`, `.png` | схема для задания 3.7 |
| `INSTRUKCIYA.md`, `KAK_ETO_RABOTAET.md`, `README.md` | документация |

**Не сдаётся, но нужно для работы:**

| Файл | Зачем |
|---|---|
| `.venv/` | виртуальное окружение с Django |
| `pyproject.toml`, `uv.lock` | список зависимостей |
| `.python-version` | версия Python |
| `shop_db.sql` | дамп базы из Прил_4 |
| `backups/` | копии базы, `tools/backup_db.sh` |

Проверить общий объём кода:

```bash
find . \( -name '*.py' -o -name '*.html' -o -name '*.css' -o -name '*.js' \) \
  | grep -v -e .venv -e __pycache__ -e backups \
  | xargs wc -l | tail -1
```

## 4. Подготовка машины

На рабочем месте нужен Python и работающий PostgreSQL.

**Проверить, что есть:**

```bash
python --version
python -c "import django; print(django.get_version())"
python -c "import psycopg; print(psycopg.__version__)"
psql --version
```

**Если чего-то нет** — через `uv`, он сам создаст окружение:

```bash
uv sync
uv run manage.py runserver
```

Или обычными средствами, если `uv` нет:

```bash
python -m venv .venv
.venv/bin/pip install django 'psycopg[binary]'
.venv/bin/python manage.py runserver
```

**Не указывай free-threaded Python.** Колес `psycopg-binary` под
свободнопоточный 3.15 не существует, они кончаются на cp313.
Установка падает с `doesn't have a source distribution or wheel
for the current platform`. В файле `.python-version` должен стоять
обычный номер версии, вроде `3.13`, без букв и без слова
`freethreaded`.

Дальше все команды Django вызываются через `.venv/bin/python`.
**Папку `.venv` на экзамен с собой не брать** — внутри абсолютные
пути к твоему Python, на чужой машине она не заработает.

**Что нужно положить в папку проекта до экзамена:**

| Что | Откуда |
|---|---|
| `shop_db.sql` | Прил_4 из КИМ |
| `static/fonts/*.ttf` (PT Sans) | Прил_1 из КИМ |
| `static/img/*.jpg` | свои картинки, на проверку не влияют |

## 5. PostgreSQL: что это и как поднять

### 5.1. Четыре слоя, из-за которых всё и ломается

Между кодом и сервером базы лежат три прослойки. Если знать их
заранее, непонятная ошибка сразу получает объяснение.

```
Django, api.py                 твой код
      │
      ▼
psycopg 3                      драйвер на Python, ставится pip
      │
      ▼
libpq                          C-библиотека, ставится пакетом ОС
      │
      ▼
postgresql                     сам сервер, отдельный процесс
```

Типичные ошибки по слоям:

| Ошибка | Что значит | Где чинить |
|---|---|---|
| `ModuleNotFoundError: psycopg` | нет драйвера | `pip install psycopg[binary]` |
| `ImportError: no pq wrapper available` | нет `libpq` | поставить системный пакет `libpq` |
| `could not translate host name` | сервер не запущен | `sudo systemctl start postgresql` |
| `password authentication failed` | неверный пароль | `ALTER ROLE conf2027 PASSWORD ...` |
| `role "conf2027" does not exist` | нет роли | создать роль (см. ниже) |

**`psycopg` против `psycopg-binary`.** Первый — чистый Python, но
ему нужна `libpq` из системы. Второй — готовый бинарник со
встроенной `libpq`, ничего доустанавливать не надо. Ставится как
`psycopg[binary]`, и это то, что нужно.

### 5.2. На обычном Linux (FHS: /etc, /var, /usr)

```bash
# Debian, Ubuntu, Mint
sudo apt install postgresql postgresql-client libpq5
# Fedora, RHEL
sudo dnf install postgresql-server postgresql libpq
# Arch
sudo pacman -S postgresql libpq

sudo systemctl enable --now postgresql
```

Что где лежит по FHS:

| Путь | Что |
|---|---|
| `/usr/lib/postgresql/<версия>/bin` | сами программы: `postgres`, `psql`, `pg_dump` |
| `/etc/postgresql/<версия>/` | конфигурация: `postgresql.conf`, `pg_hba.conf` |
| `/var/lib/postgresql/<версия>/main` | данные кластера, `PGDATA` |
| `/var/run/postgresql` | сокет для локального подключения |
| `~/.pgpass` | пароли, чтобы не вводить их каждый раз |

### 5.3. На NixOS

Пакеты не лежат в `/usr`, каждый — в своём каталоге `/nix/store`,
поэтому обычный путь не работает. В конфигурации флейка:

```nix
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
  };
}
```

После `nh os switch` появляются `psql`, `pg_dump` и служба.
Данные лежат в `/var/lib/postgresql/<версия>`, конфигурация — в
`/etc/postgresql/<версия>`.

**Главная особенность NixOS:** библиотека `libpq` не попадает в
обычный `/usr/lib`, поэтому бинарное колесо `psycopg` для
free-threaded Python может не найтись. Что делать:

```bash
# вариант 1: указать путь к libpq вручную
export LD_LIBRARY_PATH=$(dirname $(find /nix/store -name libpq.so 2>/dev/null | head -1))
python -c 'import psycopg; print(psycopg.__version__)'

# вариант 2: добавить пакет в окружение проекта
nix-shell -p python3Packages.psycopg --run "python -c 'import psycopg'"
```

### 5.4. Грабля: кластер, созданный при старой glibc

Если систему обновляли, а кластер PostgreSQL остался от прежней
версии, то `CREATE DATABASE` падает:

```
ERROR:  template database "template1" has a collation version mismatch
DETAIL: The template database was created using collation version
        2.42, but the operating system provides version 2.44.
```

Смысл: шаблон, из которого создаётся база, заведён при старой
версии glibc, и сервер отказывается его копировать. Ни одна база
при этом не создаётся — команда проходит, а базы нет.

Лечится обновлением версии коллации, один раз:

```bash
sudo -u postgres psql -d postgres \
  -c 'ALTER DATABASE postgres REFRESH COLLATION VERSION'
sudo -u postgres psql -d postgres \
  -c 'ALTER DATABASE template1 REFRESH COLLATION VERSION'
```

Шаг 2 в `tools/pg_setup.sh` делает это сам, но при ошибке
печатает готовую команду, чтобы выполнить вручную.

**Отличить эту ошибку от неверного пароля** можно по слову в
сообщении: `password authentication failed` — дело в пароле,
`role does not exist` — в отсутствии роли, `collation version` —
в кластере.

### 5.5. Роль и базы — создать один раз

Роль это пользователь в PostgreSQL, а не в Linux. Создать её
может только администратор, поэтому нужна команда с `sudo`.

```bash
sudo -u postgres psql -c \
  "CREATE ROLE conf2027 LOGIN PASSWORD 'conf2027' CREATEDB"

# база портала — модули 1-3
sudo -u postgres createdb -O conf2027 conf2027
```

Одной базы хватает. Модуль 4 вариативный, и его базу выдают на
экзамене, а в проекте для неё ничего нет.

### 5.6. Где записаны параметры подключения

Они стоят прямо в коде, обычными словами. Никаких переменных
окружения: в коде, который пишется руками, их быть не должно.

| Где | Что написано |
|---|---|
| `portal/settings.py` | словарь `DATABASES`: ENGINE, NAME, USER, PASSWORD, HOST, PORT |
| `api.py` | одна строка `DSN` со всеми параметрами сразу |
| `tools/check_autotest.py` | та же строка `DSN`, для прямых запросов в базу |

Значения везде одинаковые, имя базы везде `conf2027`. Менять
их не нужно — именно эти значения потом вводятся в проверяющую
программу, см. 5.7.

### 5.7. Что вводить в проверяющую программу

Для задания 3.4 программа спрашивает тип СУБД и доступ.
Заполняется так:

| Поле | Значение |
|---|---|
| Тип СУБД | PostgreSQL |
| Хост | `127.0.0.1` |
| Порт | `5432` |
| Пользователь | `conf2027` |
| Пароль | `conf2027` |
| Имя базы | `conf2027` |

**Простой способ не ошибиться:** заранее зайти в `psql` теми же
данными и убедиться, что вход проходит.

```bash
PGPASSWORD=conf2027 psql -h 127.0.0.1 -U conf2027 -d conf2027 -c 'SELECT 1'
```

### 5.8. Настройка одной командой

Всё описанное выше завёрнуто в скрипт `tools/pg_setup.sh`. На
экзамене достаточно одной строки:

```bash
bash tools/pg_setup.sh
```

Скрипт безопасен для повторного запуска: роль и базы, которые
уже есть, он не трогает. Что он делает по шагам:

| Шаг | Команда | Зачем |
|---|---|---|
| 1 | `sudo systemctl enable --now postgresql` | сервер запущен |
| 2 | `ALTER DATABASE ... REFRESH COLLATION VERSION` | починка кластера, см. 5.4 |
| 3 | `CREATE ROLE conf2027 LOGIN PASSWORD 'conf2027' CREATEDB` | пользователь в базе, не в Linux |
| 4 | `createdb -O conf2027 conf2027` | база портала, модули 1–3 |
| 5 | `manage.py migrate && manage.py seed` | таблицы и демо-данные |

Его содержимое:
```bash
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
```

## 6. Создание проекта

Из папки, в которой будет лежать проект:

```bash
django-admin startproject portal
cd portal
python manage.py startapp main
cd ..
```

Получится:

```
portal/          настройки проекта
  settings.py    что подключено
  urls.py        все адреса
main/            само приложение, здесь пишем всё
  models.py      таблицы
  views.py       логика страниц
  forms.py       формы
  urls.py        адреса приложения
manage.py        запуск
```

Дальше создай руками три папки и три файла — их Django не делает:

```
templates/       шаблоны страниц
static/          css, js, картинки, шрифты
mobile/          макеты под телефон
main/management/commands/   свои команды
```

И создай файл `main/management/commands/seed.py` — команда,
которая наполняет базу данными ([раздел 16](#16-начальные-данные)).

## 7. Настройки

Файл `portal/settings.py`. Отличия от созданного по умолчанию
выделены комментариями — их в проекте нет, они только тут, в
инструкции.
Ниже полный файл из проекта. Обрати внимание на три вещи,
которые легко упустить:

1. `LOGIN_URL = "login"` — без этой строки `@login_required`
   отправляет гостя на `/accounts/login/`, которого в проекте
   нет, и получается 404 вместо страницы входа.
2. `CommonMiddleware` — именно он делает редирект
   `/login` → `/login/`. Без него формы ломаются молча:
   браузер шлёт POST на адрес без слеша, Django отвечает 301,
   тело POST теряется, форма не срабатывает.
3. CSRF-токен нигде не выводится намеренно — задание прямо
   требует его отключить, иначе проверяющая система не сможет
   отправить форму.

```python
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = "django-insecure-ключ-подставь-свой"

DEBUG = True

INSTALLED_APPS = [
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "main",
]

MIDDLEWARE = [
    "django.middleware.common.CommonMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
]

ROOT_URLCONF = "portal.urls"

LOGIN_URL = "login"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "conf2027",
        "USER": "conf2027",
        "PASSWORD": "conf2027",
        "HOST": "127.0.0.1",
        "PORT": "5432",
    }
}

LANGUAGE_CODE = "ru-ru"

TIME_ZONE = "Europe/Moscow"

STATIC_URL = "static/"

STATICFILES_DIRS = [BASE_DIR / "static"]

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
```

## 8. Таблицы

По заданию в базе нужно «таблицы, поля с подходящими типами
данных и связи, непосредственно относящиеся к подрабатываемой
подсистеме». Ровно две таблицы и одна стандартная.

**Пользователи.** Отдельной таблицы нет: она уже создана Django,
лежит под именем `auth_user`. Свою `users` создавать не надо.

**`Booking` — заявка.** Поля ровно из текста задания:

| Поле | Тип | Откуда в задании |
|---|---|---|
| `user` | связь на `auth_user` | «свои ранее оставленные заявки» |
| `room_name` | текст | «введя его название в соответствующее поле» |
| `event_date` | дата | «желаемую дату начала конференции» |
| `payment_method` | выбор из двух | «при очном посещении или переводом по системе СБП» |
| `status` | выбор из трёх | «Новая», «Мероприятие назначено», «Завершено» |

**`Review` — отзыв.** Связь с заявкой один-к-одному, потому что
отзыв можно оставить только один раз, и только после того, как
заявка переведена в статус «Завершено».

Поля `room_type`, `comment`, `created_at`, `updated_at` и таблица
справочника помещений в задании не упоминаются, поэтому их нет.
Подробнее — в `KAK_ETO_RABOTAET.md`, раздел 4.
```python
from django.contrib.auth.models import User
from django.db import models


class Booking(models.Model):
    """Заявка на бронирование помещения."""

    STATUSES = [
        ("new", "Новая"),
        ("scheduled", "Мероприятие назначено"),
        ("completed", "Завершено"),
    ]
    PAYMENTS = [
        ("cash", "При очном посещении"),
        ("sbp", "Переводом по системе СБП"),
    ]
    user = models.ForeignKey(
        User, on_delete=models.CASCADE, verbose_name="пользователь"
    )
    room_name = models.CharField("помещение", max_length=120)
    event_date = models.DateField("дата начала конференции")
    payment_method = models.CharField("оплата", max_length=10, choices=PAYMENTS)
    status = models.CharField("статус", max_length=20, choices=STATUSES, default="new")

    class Meta:
        verbose_name = "заявка"
        verbose_name_plural = "заявки"
        ordering = ["-event_date", "-id"]

    def __str__(self):
        return f"{self.room_name} — {self.event_date}"


class Review(models.Model):
    """Отзыв о мероприятии. Доступен только после завершения."""

    booking = models.OneToOneField(
        Booking, on_delete=models.CASCADE, verbose_name="заявка"
    )
    rating = models.PositiveSmallIntegerField("оценка")
    text = models.TextField("текст отзыва")

    class Meta:
        verbose_name = "отзыв"
        verbose_name_plural = "отзывы"

    def __str__(self):
        return f"{self.rating} — {str(self.text)[:40]}"
```

Схема нужна для задания 3.7, лежит в `docs/ER-diagramma.svg`
и `docs/ER-diagramma.png`. Перерисовать под свои таблицы можно
чем угодно — хоть в draw.io, хоть в drawSQL, хоть в Penpot.
Главное, чтобы были видны имена таблиц, поля и связи.

## 9. Миграции

После каждого изменения `models.py` — две команды:

```bash
python manage.py makemigrations main
python manage.py migrate
```

Первая превращает модели в файл `main/migrations/0001_initial.py`,
вторая выполняет его и создаёт таблицы в PostgreSQL.

**Проверить, что таблицы появились:**

```bash
PGPASSWORD=conf2027 psql -h 127.0.0.1 -U conf2027 -d conf2027 \
  -c '\dt main_*'
```

Должны быть `main_booking` и `main_review`.

**База полностью пересоздаётся.** Если что-то испортилось и лень
разбираться, проще снести её и создать заново:

```bash
sudo -u postgres dropdb conf2027
sudo -u postgres createdb -O conf2027 conf2027
python manage.py migrate && python manage.py seed
```

После этого заявки и отзывы будут пустыми, а учётные записи
пересоздаст `seed`. Перед сносом базы сделай бэкап командой
**`bash tools/backup_db.sh`** — она копирует базу через `pg_dump`.

## 10. Проверка форматов полей

В задании форматы заданы словами, а не кодом: логин — «латиница
и цифры, не менее 6 символов», пароль — «минимум 8», ФИО —
«символы кириллицы и пробелы», телефон — «8(XXX)XXX-XX-XX».

Значит проверять надо именно так, а не только длину. Пароль и
почту Django проверяет сам (`MinLengthValidator` и
`forms.EmailField`), а вот логин, ФИО и телефон — регулярными
выражениями.
```python
import re

PATTERNS = {
    "username": (r"^[A-Za-z0-9]{6,}$", "Логин: латиница и цифры, не менее 6 символов."),
    "fio": (r"^[А-Яа-яЁё\s]+$", "ФИО: кириллица и пробелы."),
    "phone": (r"^8\(\d{3}\)\d{3}-\d{2}-\d{2}$", "Телефон: 8(XXX)XXX-XX-XX."),
}


def check_form(data):
    """Форматы полей ровно из текста задания. Почту проверяет forms.EmailField."""
    errors = {}
    for field, (pattern, message) in PATTERNS.items():
        if not re.match(pattern, data.get(field, "")):
            errors[field] = message
    return errors
```

## 11. Формы

Четыре формы. Две из них — `ModelForm`, Django сам строит поля по
модели; две — обычные `Form`, потому что пользователь Django
создаётся не через модель, а через `create_user`.

**Атрибуты `data-testid` — обязательная часть.** Их ищет
проверяющая система. Если хоть одного нет, соответствующее
задание не засчитается.

| Атрибут | Где стоит |
|---|---|
| `reg-login`, `reg-password`, `reg-fullname`, `reg-phone`, `reg-email`, `reg-submit` | `RegisterForm` и `register.html` |
| `login-login`, `login-password`, `login-submit` | `LoginForm` и `login.html` |
| `req-room`, `req-date`, `req-payment`, `req-submit` | `BookingForm` и `application_new.html` |
| `req-list` | `applications.html` |
| `req-review`, `req-rating` | `ReviewForm` и `applications.html` |
| `admin-row`, `admin-status` | `admin.html` |

Три вещи, которые тут ломаются чаще всего:

1. **`data.get()`, а не `data["поле"]`.** В методе `clean()`
   обращение через квадратные скобки к полю, которое уже не
   прошло свою проверку, вызывает `KeyError` вместо сообщения
   об ошибке.
2. **Блок `form.non_field_errors` в шаблоне обязателен.** Ошибка
   «Такой логин уже занят» добавляется через `add_error(None, ...)`,
   то есть она не привязана к полю. Без этого блока она молча
   теряется, и страница просто перерисовывается как ни в чём
   не бывало.
3. **`create_user`, а не `create`.** Только `create_user`
   хеширует пароль. `User.objects.create(password="...")`
   сохранит пароль открытым текстом, и вход перестанет работать.
```python
from django import forms
from django.contrib.auth.models import User
from django.core.validators import MinLengthValidator

from .models import Booking, Review
from .validators import check_form


class RegisterForm(forms.Form):
    username = forms.CharField(
        label="Логин", widget=forms.TextInput(attrs={"data-testid": "reg-login"})
    )
    password = forms.CharField(
        label="Пароль",
        validators=[MinLengthValidator(8)],
        widget=forms.PasswordInput(attrs={"data-testid": "reg-password"}),
    )
    password2 = forms.CharField(label="Пароль ещё раз", widget=forms.PasswordInput)
    fio = forms.CharField(
        label="ФИО", widget=forms.TextInput(attrs={"data-testid": "reg-fullname"})
    )
    phone = forms.CharField(
        label="Телефон",
        widget=forms.TextInput(
            attrs={"data-testid": "reg-phone", "placeholder": "8(999)123-45-67"}
        ),
    )
    email = forms.EmailField(
        label="Электронная почта",
        widget=forms.EmailInput(attrs={"data-testid": "reg-email"}),
    )

    def clean(self):
        data = self.cleaned_data
        for field, message in check_form(data).items():
            self.add_error(field, message)
        password = data.get("password")
        if password and password != data.get("password2"):
            self.add_error("password2", "Пароли не совпадают.")
        login = data.get("username")
        if login and User.objects.filter(username=login).exists():
            raise forms.ValidationError("Такой логин уже занят.")
        return data

    def save(self):
        user = User.objects.create_user(
            username=self.cleaned_data["username"],
            password=self.cleaned_data["password"],
            first_name=self.cleaned_data["fio"],
            email=self.cleaned_data["email"],
        )
        return user


class LoginForm(forms.Form):
    username = forms.CharField(
        label="Логин",
        widget=forms.TextInput(
            attrs={"data-testid": "login-login", "autocomplete": "username"}
        ),
    )
    password = forms.CharField(
        label="Пароль",
        widget=forms.PasswordInput(
            attrs={"data-testid": "login-password", "autocomplete": "current-password"}
        ),
    )


class BookingForm(forms.ModelForm):
    room_name = forms.CharField(
        label="Помещение",
        widget=forms.TextInput(
            attrs={"data-testid": "req-room", "placeholder": "Например: Аудитория 101"}
        ),
    )

    class Meta:
        model = Booking
        fields = ["room_name", "event_date", "payment_method"]
        widgets = {
            "event_date": forms.DateInput(
                attrs={"data-testid": "req-date", "type": "date"}, format="%Y-%m-%d"
            ),
            "payment_method": forms.Select(attrs={"data-testid": "req-payment"}),
        }


class ReviewForm(forms.ModelForm):
    class Meta:
        model = Review
        fields = ["rating", "text"]
        widgets = {
            "rating": forms.Select(
                choices=[(i, str(i)) for i in range(1, 6)],
                attrs={"data-testid": "req-rating"},
            ),
            "text": forms.Textarea(attrs={"data-testid": "req-review", "rows": 3}),
        }
```

## 12. Представления

Семь представлений, по одному на адрес.

| Представление | Адрес | Что делает |
|---|---|---|
| `index` | `/` | кто вошёл — туда и отправляет |
| `register` | `/register/` | форма регистрации, создаёт пользователя |
| `login_view` | `/login/` | вход, админа сразу ведёт в панель |
| `logout_view` | `/logout/` | выход |
| `application_new` | `/application/new/` | форма новой заявки |
| `applications` | `/applications/` | список своих заявок, отзыв, изменение, удаление |
| `admin_panel` | `/admin/` | все заявки, смена статуса |

**Разбор одного POST-обработчика по шагам.** Все три действия на
странице «Мои заявки» (отзыв, изменение, удаление) идут на один
адрес, и различаются скрытым полем `action`:

```html
<input type="hidden" name="action" value="delete">
<input type="hidden" name="booking_id" value="{{ b.id }}">
```

Во представлении сначала достаётся заявка — обязательно **с
проверкой владельца**:

```python
booking = Booking.objects.filter(
    id=request.POST.get("booking_id"), user=request.user
).first()
```

Если написать просто `Booking.objects.get(id=...)`, любой
авторизованный пользователь сможет удалить чужую заявку, просто
поменяв цифру в форме.

Дальше `action` разветвляет поведение: `review`, `update`,
`delete`. Отзыв дополнительно проверяется по статусу и по
существованию:

```python
if booking.status != "completed":
    messages.warning(request, "Отзыв доступен только после завершения.")
elif hasattr(booking, "review"):
    messages.warning(request, "Отзыв уже оставлен.")
```

Проверка статуса в представлении, а не только в шаблоне, нужна
потому, что форму можно отправить вручную, минуя страницу.
```python
from typing import cast

from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.http import HttpResponseForbidden
from django.shortcuts import redirect, render

from .forms import BookingForm, LoginForm, RegisterForm, ReviewForm
from .models import Booking


def index(request):
    if request.user.is_authenticated:
        return redirect("applications")
    return redirect("login")


def register(request):
    if request.method == "POST":
        form = RegisterForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect("login")
    else:
        form = RegisterForm()
    return render(request, "register.html", {"form": form})


def login_view(request):
    if request.method == "POST":
        form = LoginForm(request.POST)
        if form.is_valid():
            user = authenticate(
                request,
                username=form.cleaned_data["username"],
                password=form.cleaned_data["password"],
            )
            if user:
                login(request, user)
                return redirect(
                    "admin" if cast(User, user).is_staff else "applications"
                )
        form.add_error(None, "Неверный логин или пароль.")
    else:
        form = LoginForm()
    return render(request, "login.html", {"form": form})


def logout_view(request):
    logout(request)
    return redirect("login")


@login_required
def application_new(request):
    if request.method == "POST":
        form = BookingForm(request.POST)
        if form.is_valid():
            booking = form.save(commit=False)
            booking.user = request.user
            booking.save()
            messages.success(
                request,
                f"Заявка №{booking.pk} отправлена на рассмотрение администратору.",
            )
            return redirect("applications")
    else:
        form = BookingForm()
    return render(request, "application_new.html", {"form": form})


@login_required
def applications(request):
    if request.method == "POST":
        booking = Booking.objects.filter(
            id=request.POST.get("booking_id"), user=request.user
        ).first()
        action = request.POST.get("action", "")
        if not booking:
            messages.warning(request, "Заявка не найдена.")
        elif action == "review":
            if booking.status != "completed":
                messages.warning(request, "Отзыв доступен только после завершения.")
            elif hasattr(booking, "review"):
                messages.warning(request, "Отзыв уже оставлен.")
            else:
                form = ReviewForm(request.POST)
                if form.is_valid():
                    review = form.save(commit=False)
                    review.booking = booking
                    review.save()
                    messages.success(request, "Спасибо, отзыв сохранён.")
        elif action == "update":
            form = BookingForm(request.POST, instance=booking)
            if form.is_valid():
                form.save()
                messages.success(request, f"Заявка №{booking.pk} обновлена.")
        elif action == "delete":
            booking.delete()
            messages.success(request, "Заявка удалена.")
    bookings = (
        Booking.objects.filter(user=request.user)
        .select_related("review")
        .order_by("-event_date", "-id")
    )
    return render(request, "applications.html", {"bookings": bookings})


@login_required
def admin_panel(request):
    if not request.user.is_staff:
        return HttpResponseForbidden("Доступ к панели администратора запрещён.")
    labels = dict(Booking.STATUSES)
    if request.method == "POST":
        booking = Booking.objects.filter(id=request.POST.get("booking_id")).first()
        new_status = request.POST.get("status", "")
        if booking and new_status in labels:
            booking.status = new_status
            booking.save()
            done = labels[new_status]
            messages.success(request, f"Статус заявки №{booking.pk} — «{done}».")
        else:
            messages.warning(request, "Не удалось изменить статус заявки.")
    bookings = Booking.objects.select_related("user", "review")
    only = request.GET.get("status", "")
    if only in labels:
        bookings = bookings.filter(status=only)
    return render(
        request,
        "admin.html",
        {"bookings": bookings, "statuses": Booking.STATUSES, "status": only},
    )
```

## 13. Адреса

**Все адреса со слешем в конце.** Это не стилистика. Django
перенаправляет `/login` на `/login/` ответом 301, и браузер
при этом теряет тело POST. Форма будет выглядеть исправной, но
ничего не сделает.

Адреса лучше писать прямо в шаблонах (`href="/applications/"`),
а не через `{% url %}`. В проекте семь адресов, проверить их
проще, чем помнить, задан ли конкретный `name`.
```python
from django.urls import path

from . import views

urlpatterns = [
    path("", views.index, name="index"),
    path("register/", views.register, name="register"),
    path("login/", views.login_view, name="login"),
    path("logout/", views.logout_view, name="logout"),
    path("application/new/", views.application_new, name="application_new"),
    path("applications/", views.applications, name="applications"),
    path("admin/", views.admin_panel, name="admin"),
]
```

Корневой файл подключает приложение и раздаёт статику при `DEBUG`:
```python
from django.conf import settings
from django.conf.urls.static import static
from django.urls import include, path

urlpatterns = [
    path("", include("main.urls")),
] + static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])
```

## 14. Шаблоны

Два приёма, которые сокращают код и работают в любом проекте
на Django.

**Общий каркас.** Все страницы начинаются с одного файла — шапка,
меню, подвал, подключение стилей. Своя страница определяет только
блок `content`:

```html
{% extends "base.html" %}
{% block content %}
  ...своё содержимое...
{% endblock %}
```

**Общий кусок всех форм.** Разметка поля одинаковая на всех
четырех формах, поэтому вынесена в `form_fields.html` и
подключается одной строкой `{% include "form_fields.html" %}`.
Это и есть файл, который стоит держать в голове первым: в нём
разметка поля, ошибки и общие ошибки формы.
```html
{% for field in form %}
  <div class="form-group{% if field.errors %} has-error{% endif %}">
    {{ field.label_tag }}
    {{ field }}
    {% if field.help_text %}<small class="hint">{{ field.help_text }}</small>{% endif %}
    {% for error in field.errors %}<small class="error-text">{{ error }}</small>{% endfor %}
  </div>
{% endfor %}
{% if form.non_field_errors %}
  <div class="alert alert-error" role="alert">
    {% for error in form.non_field_errors %}<div>{{ error }}</div>{% endfor %}
  </div>
{% endif %}
```

Каркас:
```html
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{% block title %}Конференции.РФ{% endblock %}</title>
  <link rel="stylesheet" href="/static/style.css">
</head>
<body>

<header class="site-header">
  <div class="container header-inner">
    <a class="logo" href="/">
      <span class="logo-mark" aria-hidden="true">К</span>
      <span class="logo-text">Конференции<em>.РФ</em></span>
    </a>

    <nav class="main-nav" aria-label="Основная навигация">
      {% if user.is_authenticated %}
        <a href="/applications/">Мои заявки</a>
        <a href="/application/new/">Создать заявку</a>
        {% if user.is_staff %}
          <a href="/admin/">Панель администратора</a>
        {% endif %}
          <span class="user-chip">{{ user.username }}</span>
        <a class="nav-exit" href="/logout/">Выйти</a>
      {% else %}
        <a href="/login/">Вход</a>
        <a class="btn btn-primary btn-sm" href="/register/">Регистрация</a>
      {% endif %}
    </nav>
  </div>
</header>

<main class="container" id="main">
  {% if messages %}
    {% for message in messages %}
      <div class="alert alert-{{ message.tags }}">{{ message }}</div>
    {% endfor %}
  {% endif %}

  {% block content %}{% endblock %}
</main>

<footer class="site-footer">
  <div class="container">
    <p>Портал «Конференции.РФ» — бронирование помещений для Всероссийских конференций.</p>
    <p class="muted">Учебный проект. Специальность 09.02.07 «Информационные системы и программирование».</p>
  </div>
</footer>

<script src="/static/app.js"></script>
</body>
</html>
```

Страницы — они короткие, вся работа в разметке формы и в списке:
```html
{% extends "base.html" %}
{% block title %}Регистрация — Конференции.РФ{% endblock %}

{% block content %}
<div class="cover">
  <img src="/static/img/coworking.jpg" width="800" height="457"
    alt="Коворкинг — одно из помещений, доступных для бронирования">
</div>

<section class="card card-narrow" aria-labelledby="h-register">
  <h1 id="h-register">Регистрация</h1>
  <p class="muted">Все поля обязательны для заполнения.</p>

  <form method="post" class="form" novalidate>
    {% include "form_fields.html" %}
    <button type="submit" class="btn btn-primary btn-block" data-testid="reg-submit">Создать пользователя</button>
  </form>

  <p class="form-footer">Уже зарегистрированы? <a href="/login/">Войти</a></p>
</section>
{% endblock %}
```
```html
{% extends "base.html" %}
{% block title %}Вход — Конференции.РФ{% endblock %}

{% block content %}
<section class="card card-narrow" aria-labelledby="h-login">
  <h1 id="h-login">Вход</h1>

  <form method="post" class="form" novalidate>
    {% include "form_fields.html" %}
    <button type="submit" class="btn btn-primary btn-block" data-testid="login-submit">Войти</button>
  </form>

  <p class="form-footer">
    <a href="/register/">Еще не зарегистрированы? Регистрация</a>
  </p>
</section>
{% endblock %}
```
```html
{% extends "base.html" %}
{% block title %}Новая заявка — Конференции.РФ{% endblock %}

{% block content %}
<section class="card card-narrow" aria-labelledby="h-new">
  <h1 id="h-new">Формирование заявки</h1>
  <p class="muted">Заявка поступит на рассмотрение администратору портала.</p>

  <form method="post" class="form" novalidate>
    {% include "form_fields.html" %}

    <button type="submit" class="btn btn-primary btn-block" data-testid="req-submit">Отправить</button>
  </form>
</section>
{% endblock %}
```

Страница «Мои заявки» — самая длинная, в ней три логических
блока: карточка заявки, форма отзыва (показывается только при
статусе «Завершено») и спрятанные в `<details>` формы изменения
и удаления.
```html
{% extends "base.html" %}
{% block title %}Мои заявки — Конференции.РФ{% endblock %}

{% block content %}
<section class="page-head" aria-labelledby="h-list">
  <h1 id="h-list">Мои заявки</h1>
  <a class="btn btn-primary" href="/application/new/">Создать заявку</a>
</section>

{% if not bookings %}
  <div class="card card-empty">
    <p>Заявок пока нет.</p>
    <a class="btn btn-primary" href="/application/new/">Забронировать помещение</a>
  </div>
{% else %}
  <div class="card-list" data-testid="req-list">
    {% for b in bookings %}
      <article class="card booking">
        <div class="booking-head">
          <h2>{{ b.room_name }}</h2>
          <span class="badge status-{{ b.status }}">{{ b.get_status_display }}</span>
        </div>

        <dl class="booking-info">
          <div><dt>Дата конференции</dt><dd>{{ b.event_date }}</dd></div>
          <div><dt>Способ оплаты</dt><dd>{{ b.get_payment_method_display }}</dd></div>
          <div><dt>Номер заявки</dt><dd>#{{ b.id }}</dd></div>
        </dl>

        {% if b.review %}
          <div class="review">
            <div class="rating" aria-label="Оценка {{ b.review.rating }} из 5">
              {{ "★"|slice:":"|default:"" }}{% for i in "12345"|make_list %}{% if forloop.counter <= b.review.rating %}★{% else %}☆{% endif %}{% endfor %}
            </div>
            <p>{{ b.review.text }}</p>
            <small class="muted">Ваш отзыв</small>
          </div>

        {% elif b.status == "completed" %}
          <p class="muted">Мероприятие завершено — вы можете оставить отзыв.</p>

          <form method="post" class="form review-form">
            <input type="hidden" name="action" value="review">
            <input type="hidden" name="booking_id" value="{{ b.id }}">

            <div class="form-group">
              <label for="rating-{{ b.id }}">Оценка</label>
              <select id="rating-{{ b.id }}" name="rating" data-testid="req-rating">
                <option value="">Выберите оценку</option>
                <option value="5">5 — отлично</option>
                <option value="4">4 — хорошо</option>
                <option value="3">3 — нормально</option>
                <option value="2">2 — плохо</option>
                <option value="1">1 — очень плохо</option>
              </select>
            </div>

            <div class="form-group">
              <label for="review-{{ b.id }}">Отзыв</label>
              <textarea id="review-{{ b.id }}" name="text" rows="3" maxlength="500"
                data-testid="req-review"
                placeholder="Как прошло мероприятие?"></textarea>
            </div>

            <button type="submit" class="btn btn-primary">Отправить отзыв</button>
          </form>

        {% else %}
          <p class="muted small">
            Отзыв станет доступен после того, как администратор
            переведёт заявку в статус «Завершено».
          </p>
        {% endif %}

        <details class="row-actions">
          <summary>Изменить или удалить заявку</summary>

          <form method="post" class="inline-form">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="booking_id" value="{{ b.id }}">
            <input type="date" name="event_date" value="{{ b.event_date|date:'Y-m-d' }}"
              data-testid="req-edit-date" aria-label="Новая дата">
            <button type="submit" class="btn btn-secondary btn-sm"
              data-testid="req-update">Сохранить</button>
          </form>

          <form method="post" class="inline-form">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="booking_id" value="{{ b.id }}">
            <button type="submit" class="btn btn-danger btn-sm"
              data-testid="req-delete">Удалить заявку</button>
          </form>
        </details>
      </article>
    {% endfor %}
  </div>
{% endif %}
{% endblock %}
```

Панель администратора:
```html
{% extends "base.html" %}
{% block title %}Панель администратора — Конференции.РФ{% endblock %}

{% block content %}
<section class="page-head" aria-labelledby="h-admin">
  <h1 id="h-admin">Панель администратора</h1>
  <span class="muted">Вы вошли как {{ user.username }}</span>
</section>

<form method="get" action="/admin/" class="filter-bar">
  <label for="status">Показывать заявки со статусом:</label>
  <select name="status" id="status">
    <option value="">все</option>
    {% for value, label in statuses %}
      <option value="{{ value }}" {% if status == value %}selected{% endif %}>{{ label }}</option>
    {% endfor %}
  </select>
  <button type="submit" class="btn btn-secondary">Показать</button>
</form>

{% if not bookings %}
  <div class="card card-empty"><p>Заявок с таким статусом нет.</p></div>
{% else %}
  <div class="card table-wrap">
    <table class="data-table">
      <thead>
        <tr>
          <th scope="col">№</th>
          <th scope="col">Пользователь</th>
          <th scope="col">Помещение</th>
          <th scope="col">Статус</th>
          <th scope="col">Смена статуса</th>
        </tr>
      </thead>
      <tbody>
        {% for b in bookings %}
          <tr data-testid="admin-row">
            <td data-label="№">{{ b.id }}</td>
            <td data-label="Пользователь">{{ b.user.first_name }}<br>
              <small class="muted">{{ b.user.username }}</small></td>
            <td data-label="Помещение">{{ b.room_name }}<br>
              <small class="muted">{{ b.event_date|date:"d.m.Y" }}</small></td>
            <td data-label="Статус">{{ b.get_status_display }}</td>
            <td data-label="Смена статуса">
              <form method="post" class="inline-form">
                <input type="hidden" name="booking_id" value="{{ b.id }}">
                <select name="status" data-testid="admin-status">
                  {% for value, label in statuses %}
                    <option value="{{ value }}"
                      {% if b.status == value %}selected{% endif %}>{{ label }}</option>
                  {% endfor %}
                </select>
                <button type="submit" class="btn btn-sm">Сохранить</button>
              </form>
            </td>
          </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
{% endif %}
{% endblock %}
```

## 15. Вёрстка, адаптивность и анимация

### 14.1. Что берётся из задания, а что выбираешь сам

Задание 2.1 задаёт корпоративный стиль: палитру, шрифт PT Sans
и размеры заголовков. Эти значения проверяются, их менять нельзя.

| Что | Значение |
|---|---|
| Основной голубой | `#007bff` |
| Тёмно-синий | `#0d47a1` |
| Серый | `#6c757d` |
| Фон | `#f8f9fa` |
| Выделяющий белый | `#ffffff` |
| H1 | 36px, жирный |
| H2 | 24px, жирный |
| H3 | 18px, жирный |
| Обычный текст | 16px |
| Вспомогательный | 12px, курсив |

Шрифты лежат в `static/fonts/` — это файлы из Прил_1. Подключать
локально, сети на экзамене нет.

### 14.2. Восемь приёмов, которые решают почти всё

**1. Переменные в `:root`.**
Цвета и отступы один раз, дальше по именам. Меняешь палитру —
меняешь в одном месте, а не в сорока строках.

```css
:root {
  --blue: #007bff;
  --dark: #0d47a1;
  --gray: #6c757d;
  --bg: #f8f9fa;
  --white: #ffffff;
}
```

**2. Список вместо селектора на шесть тегов.**
Поля ввода, выпадающие списки и textarea стилизуются одинаково.
Один селектор с запятой короче шести отдельных и ничего не
забывает:

```css
input, select, textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #ced4da;
  border-radius: 6px;
  font: inherit;
}
```

**3. Один медиазапрос вместо трёх.**
Адаптив нужен один — там, где таблица перестаёт помещаться. Порог
считается так: восемь колонок самой широкой таблицы плюс отступы
дают примерно 860 пикселей. Ниже — таблица превращается в
набор карточек, а `data-label` показывает, что было в колонке.

**4. `flex-basis` в колонке задаёт высоту, а не ширину.**
Самая частая ошибка. Если нужно разделить ширину — используй
`grid-template-columns`. В проекте панель фильтра сделана так:

```css
.filter-bar {
  display: grid;
  grid-template-columns: 2fr 1fr auto;
  gap: 12px;
  align-items: end;
}
```

**5. `width: 1px` в шапке таблицы.**
Без него таблица растёт под содержимое ячеек и страница
уезжает вбок. С ним ширина делится по содержимому, как задумано.

**6. Анимация без единой строки JavaScript.**
Задание 3.6 требует анимацию. Достаточно `transition` в базовом
правиле и `:hover` — и она есть на всех страницах, потому что
стиль один общий:

```css
.btn {
  transition: background-color .18s ease, box-shadow .18s ease;
}
.btn:hover {
  box-shadow: 0 2px 8px rgba(13, 71, 161, .25);
}
```

**7. Семантические теги вместо классов.**
`<header>`, `<nav>`, `<main>`, `<section>`, `<footer>` вместо
`<div class="header">`. Задание 3.5 требует HTML5-элементы, и за
тот же код стилизуется через тег, а не через класс.

**8. Один файл стилей на весь проект.**
Отдельный `mobile/style.css` был бы второй системой оформления,
которую пришлось бы поддерживать. Макеты подключают
`../static/style.css` — тот же самый.

### 14.3. Полный файл стилей

223 строки, весь вид сайта. Читать его надо целиком — это
основа, на которой стоит всё остальное.
```css
@font-face {
  font-family: "PT Sans";
  src: url("/static/fonts/PTSans-Regular.ttf") format("truetype");
  font-weight: 400; font-style: normal;
  font-display: swap;
}
@font-face {
  font-family: "PT Sans";
  src: url("/static/fonts/PTSans-Bold.ttf") format("truetype");
  font-weight: 700; font-style: normal;
  font-display: swap;
}
@font-face {
  font-family: "PT Sans";
  src: url("/static/fonts/PTSans-Italic.ttf") format("truetype");
  font-weight: 400; font-style: italic;
  font-display: swap;
}

:root {
  --blue: #007bff;         /* основной голубой */
  --dark-blue: #0d47a1;    /* тёмно-синий */
  --gray: #6c757d;
  --bg: #f8f9fa;
  --white: #ffffff;
  --light-blue: #e7f1ff;
  --border: #dee2e6;
  --danger: #dc3545;
  --h1: 36px;
  --t: .2s;
}

*, *::before, *::after { box-sizing: border-box; }

body {
  margin: 0; font-family: "PT Sans", Arial, sans-serif; font-size: 16px;
  line-height: 1.55; color: #212529; background: var(--bg);
  display: flex; flex-direction: column; min-height: 100vh;
}

h1 { font-size: var(--h1); margin: 0 0 16px; }
h2 { font-size: 24px; margin: 0 0 12px; }
h3 { font-size: 18px; margin: 0 0 8px; }
p { margin: 0 0 16px; }

small, .muted, .hint, .small {
  font-size: 12px; font-style: italic; color: var(--gray);
}

a { color: var(--blue); text-decoration: none; transition: color var(--t); }
a:hover { color: var(--dark-blue); text-decoration: underline; }

.container { width: 100%; max-width: 1000px; margin: 0 auto; padding: 0 16px; }
main.container { flex: 1 0 auto; padding: 24px 16px 48px; }

.site-header { background: var(--white); border-bottom: 3px solid var(--blue); }
.site-footer { background: var(--white); border-top: 3px solid var(--blue); padding: 16px 0; font-size: 14px; color: var(--gray); }

.header-inner, .page-head, .booking-head {
  display: flex; justify-content: space-between; align-items: center;
  gap: 16px; flex-wrap: wrap;
}
.header-inner { min-height: 64px; }
.page-head { margin-bottom: 16px; }
.page-head h1 { margin: 0; }

.logo { display: flex; align-items: center; gap: 8px; font-size: 20px; font-weight: 700; color: var(--dark-blue); }
.logo:hover { text-decoration: none; }
.logo-mark {
  width: 34px; height: 34px; display: grid; place-items: center;
  background: var(--blue); color: var(--white); border-radius: 5px;
}
.logo-text em { font-style: normal; color: var(--blue); }

.main-nav { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; font-size: 14px; }
.main-nav a { color: var(--gray); }
.main-nav a:hover { color: var(--blue); text-decoration: none; }
.nav-exit { border-left: 1px solid var(--border); padding-left: 16px; }
.user-chip {
  background: var(--light-blue); color: var(--dark-blue);
  padding: 4px 12px; border-radius: 20px; font-weight: 700; font-style: normal;
}

.card {
  background: var(--white); border: 1px solid var(--border);
  border-radius: 8px; box-shadow: 0 1px 3px rgba(13, 71, 161, .1);
  padding: 24px; margin-bottom: 16px;
  transition: box-shadow var(--t), transform var(--t), border-color var(--t);
}
.card:hover { box-shadow: 0 6px 24px rgba(13, 71, 161, .16); transform: translateY(-2px); }
.card-narrow { max-width: 540px; margin: 0 auto 16px; }
.card-empty { text-align: center; padding: 48px 24px; }
.card-list { display: grid; gap: 16px; }

.form, .form-group { display: flex; flex-direction: column; gap: 16px; }
.form-group { gap: 4px; }
.status-form, .inline-form {
  display: flex; gap: 8px; flex-wrap: wrap; align-items: center;
}
.filter-bar {
  display: grid; grid-template-columns: 1fr auto; gap: 8px;
  align-items: center; margin-bottom: 16px;
}
.filter-bar label { grid-column: 1 / -1; margin-bottom: -4px; }
.inline-form select { width: auto; }
.form-group label { font-weight: 700; font-size: 14px; color: var(--dark-blue); }

input, select, textarea {
  font-family: inherit; font-size: 16px; color: #212529;
  background: var(--white); border: 1px solid #ced4da; border-radius: 5px;
  padding: 10px 12px; width: 100%; transition: border-color var(--t);
}
textarea { min-height: 80px; resize: vertical; }
input:focus, select:focus, textarea:focus {
  outline: none; border-color: var(--blue);
  box-shadow: 0 0 0 3px rgba(0, 123, 255, .18);
}

.error-text { font-size: 12px; font-style: italic; font-weight: 700; color: var(--danger); }
.has-error input, .has-error select, .has-error textarea { border-color: var(--danger); }
.form-footer { margin: 16px 0 0; text-align: center; font-size: 14px; }

.btn {
  display: inline-flex; align-items: center; justify-content: center;
  font-family: inherit; font-size: 16px; font-weight: 700;
  border: 1px solid transparent; border-radius: 5px;
  padding: 10px 20px; cursor: pointer;
  transition: background var(--t), color var(--t), border-color var(--t);
}
.btn-primary { background: var(--blue); color: var(--white); }
.btn-primary:hover { background: var(--dark-blue); }
.btn-secondary { background: var(--white); color: var(--dark-blue); border-color: var(--blue); }
.btn-secondary:hover { background: var(--light-blue); }
.btn-danger { background: var(--danger); color: var(--white); }
.btn-sm { padding: 6px 14px; font-size: 14px; }
.btn-block { width: 100%; }

.alert {
  border: 1px solid transparent; border-radius: 5px;
  padding: 12px 16px; margin-bottom: 16px; font-size: 14px;
  animation: slide-in .35s;
}
.alert-error { background: #f8d7da; color: #721c24; }
.alert-success { background: #d4edda; color: #155724; }

.badge {
  display: inline-block; font-size: 12px; font-weight: 700;
  padding: 4px 12px; border-radius: 20px;
}
.status-new { background: #fff3cd; color: #856404; }
.status-scheduled { background: var(--light-blue); color: var(--dark-blue); }
.status-completed { background: #d4edda; color: #155724; }

.booking-info {
  display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
  gap: 8px 16px; margin: 0 0 12px;
}
.booking-info dt { font-size: 12px; font-style: italic; color: var(--gray); }
.booking-info dd { margin: 0; font-weight: 700; }
.booking-head h2 { margin: 0; }

.review {
  background: var(--bg); border-left: 3px solid var(--blue);
  border-radius: 5px; padding: 12px 16px;
}
.review p { margin: 4px 0 0; }
.rating { color: #ffc107; font-size: 20px; }
.review-form { margin-top: 16px; animation: slide-in .35s; }


.table-wrap { overflow-x: auto; }
.data-table { width: 100%; border-collapse: collapse; font-size: 14px; }
.data-table th, .data-table td {
  text-align: left; padding: 10px 12px; vertical-align: top;
  border-bottom: 1px solid var(--border);
}
.data-table th { background: var(--light-blue); color: var(--dark-blue); font-size: 12px; text-transform: uppercase; }
.data-table tbody tr { transition: background var(--t); }
.data-table tbody tr:hover { background: var(--light-blue); }

.row-actions {
  margin-top: 16px; padding-top: 12px;
  border-top: 1px dashed var(--border); font-size: 14px;
}
.row-actions summary { cursor: pointer; font-weight: 700; color: var(--gray); }
.row-actions summary:hover { color: var(--blue); }

.cover img { display: block; width: 100%; height: auto; border-radius: 8px; }

@keyframes slide-in { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
@keyframes fade-in  { from { opacity: 0; } to { opacity: 1; } }

@media (max-width: 860px) {
  h1 { font-size: 28px; }
  h2 { font-size: 20px; }

  .header-inner, .page-head, .status-form, .inline-form {
    flex-direction: column; align-items: stretch;
  }
  .filter-bar { grid-template-columns: 1fr; }
  .card { padding: 16px; }
  .booking-info { grid-template-columns: 1fr; }
  .btn { width: 100%; }

  .table-wrap { overflow-x: visible; }
  .data-table thead {
    position: absolute; width: 1px; height: 1px;
    overflow: hidden; clip: rect(0 0 0 0);
  }
  .data-table, .data-table tbody, .data-table tr, .data-table td { display: block; width: 100%; }
  .data-table tr { border: 1px solid var(--border); border-radius: 8px; margin-bottom: 12px; }
  .data-table td { border: 0; display: flex; justify-content: space-between; gap: 16px; }
  .data-table td::before {
    content: attr(data-label);
    font-weight: 700; font-size: 12px; text-transform: uppercase; color: var(--gray);
  }
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation: none; transition: none; }
}
```

JavaScript — одна функция, 16 строк, подтверждение смены статуса:
```javascript
document.addEventListener('submit', function (event) {
  var form = event.target.closest('.status-form');
  if (!form) {
    return;
  }

  var select = form.querySelector('select[name=status]');
  if (!select) {
    return;
  }

  var chosen = select.options[select.selectedIndex].text;
  if (!window.confirm('Изменить статус заявки на «' + chosen + '»?')) {
    event.preventDefault();
  }
});
```

## 16. Начальные данные

Задание не требует данных, но без них нечего показать
проверяющей системе: пустой список заявок не даёт ни одного
сработавшего сценария.

Данные добавляет своя команда Django. Файл лежит в
`main/management/commands/seed.py`, вызывается как
`python manage.py seed`.

Что создаётся: три учётные записи (администратор и два
пользователя) и две заявки — одна в статусе «Завершено», чтобы
было видно форму отзыва, одна «Новая».

Команда безопасная для повторного запуска: использует
`get_or_create`, поэтому второй вызов не создаст дубликатов.
```python
import datetime as dt

from django.contrib.auth.models import User
from django.core.management import BaseCommand

from main.models import Booking


class Command(BaseCommand):
    help = "Создаёт учётные записи и демонстрационные заявки"

    def handle(self, *args, **options):
        users = [
            ("Conf2027", "Demo77", "Администратор Портала", True),
            ("ivanov", "user1234", "Иванов Иван Иванович", False),
            ("petrova", "user1234", "Петрова Анна Сергеевна", False),
        ]
        for login, password, fio, staff in users:
            user, _ = User.objects.get_or_create(username=login)
            user.first_name = fio
            user.is_staff = staff
            user.is_superuser = staff
            user.set_password(password)
            user.save()
        self.stdout.write(f"Пользователей: {User.objects.count()}")
        today = dt.datetime.now(tz=dt.timezone.utc).astimezone().date()
        bookings = [
            ("petrova", "Кинозал «Заря»", 2, "cash", "completed"),
            ("ivanov", "Аудитория 101", 5, "sbp", "new"),
        ]
        for login, room, days, payment, status in bookings:
            Booking.objects.get_or_create(
                user=User.objects.get(username=login),
                room_name=room,
                defaults={
                    "event_date": today + dt.timedelta(days=days),
                    "payment_method": payment,
                    "status": status,
                },
            )
        self.stdout.write(f"Заявок: {Booking.objects.count()}")
        self.stdout.write(self.style.SUCCESS("Готово."))
```

Учётные записи после `seed`:

| Логин | Пароль | Кто |
|---|---|---|
| `Conf2027` | `Demo77` | администратор (вход сразу в `/admin/`) |
| `ivanov` | `user1234` | пользователь |
| `petrova` | `user1234` | пользователь, у неё заявка в статусе «Завершено» |

## 17. Макеты (модуль 2)

Задание 2.1 просит пять макетов под 390×844 и архив
`layout_2.zip`. Макеты лежат в `mobile/`, по одному файлу на
страницу, имена латиницей.

| Файл | Страница |
|---|---|
| `login.html` | Вход |
| `register.html` | Регистрация |
| `new-request.html` | Формирование заявки |
| `requests.html` | Мои заявки |
| `admin.html` | Панель администратора |

**Почему имена латиницей.** Утилита `zip` записывает имена с
кириллицей без флага UTF-8, и на Windows такие файлы
распаковываются «кракозябрами». Экзамен проходит на Windows, где
архив собирается штатным «Сжатая ZIP-папка» — вот там выигрывает
кириллица. Внутри архива, который ты приносишь на флешке,
латиница безопаснее. Собирать архив Python-скриптом не обязательно:
достаточно не называть файлы по-русски.

Каждый макет — самодостаточный HTML-файл с шириной 390:

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

Подключается общий стиль проекта, отдельного своего нет.

**Исходник дизайна.** Задание 2.1 просит исходник — файл
`.fig`, `.psd`, `.xcf` или `.afdesign`. Это единственный пункт,
который руками в коде не закрывается: нужен графический редактор
на рабочем месте (Penpot, Lunacy, GIMP). Penpot умеет отдавать
исходник сам — файл `.penpot` это обычный ZIP с JSON внутри,
он открывается в текстовом редакторе.

## 18. Модуль 4, API заказов

Отдельная программа, Django здесь не нужен. `api.py` работает через
`psycopg` напрямую: читает готовую базу и отдаёт её через
стандартный `http.server`.

**Модуль вариативный.** На пробном демонстрационном экзамене его
может не быть вовсе, а база для него выдаётся на месте и
разворачивается тем дампом, который выдали. Поэтому в проекте для
него нет ни базы, ни скрипта настройки — только сам `api.py` с
одной строкой `DSN`, которую надо поправить под свою базу.

В коде — только: `http.server` и `urllib.parse`.

**Что требуется по заданию:**

| Требование | Как сделано |
|---|---|
| `GET /orders`, по возрастанию `id` | `ORDER BY id ASC` |
| Поля заказа | ровно перечислены в задании, лишних нет |
| Статусы по-русски | словарь `STATUS_RU` и `.get()` с запасным значением |
| Дата в виде `ДД.ММ.ГГГГ` | `datetime.strptime` + `strftime` |
| ФИО одной строкой, без лишнего пробела | `" ".join(filter(None, (...)))` — пустые части просто исчезают |
| Адрес одной строкой, без квартиры если её нет | `make_address` добавляет `кв.` только когда поле не пустое |
| Сумма и цены с двумя знаками | f-строка `f"{сумма:.2f}"` |
| Фильтр `?status=` и `?user_id=`, соединяются по И | условия собираются в строку `WHERE` |
| Пустой результат — 200 и `[]` | так и возвращается |
| Неизвестный статус или нецелый `user_id` — 400 | проверка до запроса к базе |
| База недоступна — 500 | `try/except` вокруг всей работы с базой |
| Тело ошибки — объект с единственным полем `error` | `send_json(code, {"error": ...})` |

**Запуск:**

```bash
python api.py
# API: http://127.0.0.1:8081/orders
```

Порт меняется переменной окружения `CONF_API_PORT`.

**База.** Дамп `shop_db.sql` выдают на экзамене, и задание 4.1
требует развернуть его самому — это отдельный шаг, не работа
приложения. В проекте для этого ничего нет: поправить надо одну
строку `DSN` в начале `api.py`.

Проверить можно так:

```bash
curl -s http://127.0.0.1:8081/orders
curl -s 'http://127.0.0.1:8081/orders?status=done'
curl -s 'http://127.0.0.1:8081/orders?user_id=1'
curl -s -o /dev/null -w '%{http_code}\n' 'http://127.0.0.1:8081/orders?status=xxx'
```

Последняя команда должна напечатать `400`.
```python
import json
import os
import re
from datetime import date
from http.server import BaseHTTPRequestHandler, HTTPServer
from typing import Any, cast
from urllib.parse import parse_qs, urlparse

import psycopg
from psycopg.rows import dict_row

DSN = "dbname=shop user=conf2027 password=conf2027 host=127.0.0.1 port=5432"

STATUS_RU = {
    "new": "Новый",
    "paid": "Оплачен",
    "shipped": "Отправлен",
    "done": "Завершён",
    "cancelled": "Отменён",
}


def connect():
    return psycopg.connect(DSN, row_factory=cast(Any, dict_row))


def make_customer(user):
    return " ".join(
        filter(None, (user["last_name"], user["first_name"], user["middle_name"]))
    )


def make_address(user):
    address = f"г. {user['city']}, ул. {user['street']}, д. {user['house']}"
    if user["flat"]:
        address += f", кв. {user['flat']}"
    return address


def make_date(value):
    return date.fromisoformat(value[:10]).strftime("%d.%m.%Y")


def build_order(connection, order):
    user = connection.execute(
        "SELECT * FROM users WHERE id = %s", (order["user_id"],)
    ).fetchone()
    rows = connection.execute(
        """
        SELECT p.title, oi.quantity, p.price
          FROM order_items oi
          JOIN products p ON p.id = oi.product_id
         WHERE oi.order_id = %s
         ORDER BY oi.id
        """,
        (order["id"],),
    ).fetchall()
    items = [(row["title"], row["quantity"], float(row["price"])) for row in rows]

    return {
        "order_id": order["id"],
        "customer": make_customer(user),
        "status": STATUS_RU.get(order["status"], order["status"]),
        "created_at": make_date(order["created_at"]),
        "address": make_address(user),
        "items_count": len(items),
        "total": f"{sum(q * p for _, q, p in items):.2f}",
        "items": [
            {"title": t, "quantity": q, "price": f"{p:.2f}"} for t, q, p in items
        ],
    }


def handle_orders(query):
    status = query.get("status", [None])[0]
    user_id = query.get("user_id", [None])[0]
    if status is not None and status not in STATUS_RU:
        return 400, {"error": "Недопустимое значение параметра status"}
    if user_id is not None:
        if not re.fullmatch(r"-?\d+", user_id.strip()):
            return 400, {"error": "Недопустимое значение параметра user_id"}
        user_id = int(user_id)
    conditions, args = [], []
    if status:
        conditions.append("status = %s")
        args.append(status)
    if user_id is not None:
        conditions.append("user_id = %s")
        args.append(user_id)

    where = " WHERE " + " AND ".join(conditions) if conditions else ""
    query = f"SELECT * FROM orders{where} ORDER BY id ASC"

    try:
        connection = connect()
        try:
            rows = connection.execute(query, args).fetchall()
            result = [build_order(connection, row) for row in rows]
        finally:
            connection.close()
    except (OSError, psycopg.Error) as exc:
        return 500, {"error": f"Внутренняя ошибка сервера: {exc}"}
    return 200, result


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path.rstrip("/") == "/orders":
            code, body = handle_orders(parse_qs(parsed.query))
        else:
            code, body = 404, {"error": "Ресурс не найден"}
        self.send_json(code, body)

    def send_json(self, code, body):
        payload = json.dumps(body, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


def main():
    port = int(os.environ.get("CONF_API_PORT", "8081"))
    server = HTTPServer(("127.0.0.1", port), Handler)
    print("=" * 66)
    print(f" API заказов:  http://127.0.0.1:{port}/orders")
    print(f" Пример:       http://127.0.0.1:{port}/orders?status=done&user_id=1")
    print("=" * 66)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nОстановлено")
        server.server_close()


if __name__ == "__main__":
    main()
```

## 19. Проверка перед сдачей

В проекте есть готовая проверка — 46 сквозных проверок, каждая
начинает настоящий сеанс с браузера.

```bash
python tools/check_autotest.py http://127.0.0.1:8001
```

**Без работающего сервера** проверяется только то, что можно
проверить по тексту:

Проверить, что имена таблиц и колонок совпадают с базой, можно
глазами:

```bash
PGPASSWORD=conf2027 psql -h 127.0.0.1 -U conf2027 -d conf2027 \
  -c '\\d main_booking'
```

Ожидается `Пройдено: 46    Ошибок: 0`. Проверяет: регистрацию
с ошибками и без, вход и выход, создание заявки, изменение,
удаление, отзыв только после завершения, смену статуса
администратором, запрет доступа к панели обычному пользователю,
наличие всех `data-testid`, отсутствие переполнения.

**Ручная проверка — список, который стоит пройти глазами:**

| Что | Как |
|---|---|
| Корень не 404 | `/` отдаёт 302 на `/login/` или `/applications/` |
| Гость не видит закрытых страниц | `/applications/`, `/admin/` уводят на `/login/` |
| Пустые адреса со слешем | `/login` работает так же, как `/login/` |
| 17 `data-testid` | `grep -o 'data-testid="[^"]*" templates/*.html main/forms.py` |
| Анимация | `:hover` на кнопках есть, страница не «дёргается» |
| Адаптив | окно 390, 768, 1440 — горизонтальной прокрутки нет |
| HTML5-теги | `<header>`, `<nav>`, `<main>`, `<section>`, `<footer>` есть на всех страницах |
| Нет ошибок в консоли | F12, вкладка Console, при навигации чисто |
| CSRF отключён | DevTools → Network → у запросов нет `csrftoken` |
| SQL-запросы | `python manage.py check`, без предупреждений |
| Django другой версии | 5.2 и 6.1 оба чисты |

## 20. Три архива

Задание требует три архива, и каждый собирается своим способом.

| Архив | Что внутри | Требование |
|---|---|---|
| `project_1.zip` | вся папка проекта вместе с `.git` | задание 1.6 |
| `layout_2.zip` | папка `mobile/` | задание 2.1 |
| `project_3.zip` | папка проекта без `.git` и без `.venv` | задания 3.1–3.7 |

**Кириллица в именах файлов.** Утилита `zip` из Linux не ставит
флаг UTF-8 (бит `0x800`) в заголовке имени, и на Windows файлы
распаковываются «кракозябрами». Python-модуль `zipfile` ставит
флаг сам, поэтому надёжнее собрать архив им:

```python
import zipfile

with zipfile.ZipFile("project_3.zip", "w", zipfile.ZIP_DEFLATED) as z:
    z.write("main/views.py", "conf2027_django/main/views.py")
```

Проверить, что флаг выставлен:

```python
import zipfile

with zipfile.ZipFile("project_3.zip") as z:
    for i in z.infolist():
        assert not (not i.flag_bits & 0x800 and not i.filename.isascii())
print("флаги в порядке")
```

**Что обязательно должно быть в `project_1.zip`:** папка `.git`,
потому что задание 1.6 проверяет историю коммитов. Несколько
осмысленных коммитов: в начале работы и в конце.

**Чего в архиве быть не должно:** `.venv`, `backups/`,
`__pycache__`. Виртуальное окружение внутри архива весит
десятки мегабайт и на другой машине всё равно не работает.

## 21. Тайминг на 4 часа

16 из 19 заданий — краткий ответ, три задания дают файл:
1.6, 2.1 и 3.7. То есть файлы сдаёт только треть работы.

| Когда | Что | Минут |
|---|---|---|
| 0:00 | прочитать модули 1 и 3, разметить 16 кратких ответов | 25 |
| 0:25 | регистрация, вход, выход | 30 |
| 0:55 | таблицы и миграции | 15 |
| 1:10 | заявка: создание | 20 |
| 1:30 | заявки: список, изменение, удаление | 25 |
| 1:55 | отзыв | 15 |
| 2:10 | панель администратора, смена статуса | 20 |
| 2:30 | адаптивность и анимация | 20 |
| 2:50 | HTML5-теги | 10 |
| 3:00 | макеты 390×844 и `layout_2.zip` | 25 |
| 3:25 | API заказов | 25 |
| 3:50 | ER-схема, коммиты, три архива | 10 |

Анимацию, макеты и API лучше делать в конце: на них нет
промежуточных проверок, они либо работают, либо нет, а основные
задания проверяются после каждого шага.

## 22. Грабли

Каждая строка — реальная ошибка, которая либо случилась, либо
проверялась специально.

### Django

**Адрес без слеша в конце теряет POST.** `/login` и `/login/` —
разные адреса. Ответ 301, тело запроса не доходит, форма
выглядит рабочей, но ничего не делает. Все адреса со слешем.

**`data["поле"]` в `clean()` даёт `KeyError`.** Если поле не
прошло свою проверку, его нет в `cleaned_data`. Писать
`data.get("поле")`.

**`User.objects.create(password=...)` не хеширует пароль.**
Только `create_user` или `set_password`.

**`get_or_create(defaults=dict(password=...))` тоже не хеширует.**
Внутри него лежит `create`, а не `create_user`.

**Расширять чужую модель через `add_to_class` нельзя.** Миграция
уезжает внутрь `.venv`, на чужой машине её нет, и проект не
поднимается. Своя модель с `OneToOneField` — единственный
безопасный путь.

**`SubmitInput` удалён в Django 6.** У `DateInput` нет
`attrs_format`.

**`DEFAULT_AUTO_FIELD` нужен в обеих версиях.** В Django 6 это
умолчание, в Django 5 — нет, и появляются четыре предупреждения
`models.W042`.

**`AddToApp` / `ADMIN` не работает без `django.contrib.admin`,
которого в проекте нет.** Панель администратора здесь своя,
обычным представлением с проверкой `is_staff`.

### Шаблоны

**Без `form.non_field_errors` теряются общие ошибки.**
«Логин уже занят» добавляется через `add_error(None, ...)`, к
полю не привязана, и без блока просто исчезает.

**Словарь в шаблоне печатается как есть.** `{{ some_dict }}`
даст `{'audience': 'Аудитория'}`, а не подпись. Словарь
преобразуется в представлении или хранит уже готовую строку.

### Вёрстка

**`flex-basis` в `flex-direction: column` задаёт высоту.**
Поле поиска растёт на пол-экрана по высоте. Нужна ширина —
используй `grid-template-columns`.

**Без `width: 1px` таблица растягивает страницу.** Восемь
колонок плюс отступы дают 612 пикселей при окне в 390.

**Автоматический пересчёт отступов в шаблонах Django не
работает.** `{% %}` внутри строки сбивает определение уровня,
многострочные теги не распознаются. Делить отступы на 2 целиком
(кратно 4), единицы править руками.

### Формы

**Пароль создаётся только `create_user`.**

**`User.objects.make_random_password()` в Django 6
не существует.** Вместо него
`django.utils.crypto.get_random_string(12)`.

### PostgreSQL

**Плейсхолдер в SQL — всегда `%s`.** Это синтаксис PostgreSQL.
Другой вариант, кстати, не `?`, а `:имя`, и он тоже работает, но
смешивать их в одном запросе нельзя — сервер вернёт ошибку.

**Файл базы копировать нельзя.** Данные лежат у сервера, а не в
папке проекта, поэтому `cp` не работает. Бэкап — это `pg_dump`.

**Роль в PostgreSQL и пользователь в Linux — разные вещи.**
Роль `conf2027` создаётся командой от пользователя `postgres`,
и для этого нужен `sudo`. Ошибка «role does not exist» означает
ровно одно: роль не создана, логином это не лечится.

**`psycopg-binary` не собирается под free-threaded Python.**
Колёс для `cp315t` нет, и `pip install psycopg[binary]` падает
с ошибкой про ABI. Лечится обычным Python 3.13 либо указанием
пути к `libpq` через `LD_LIBRARY_PATH`.

**`libpq` на NixOS не лежит в `/usr/lib`.** Каждый пакет в своём
каталоге `/nix/store`, поэтому чистый `psycopg` не находит её
и пишет `no pq wrapper available`.

### Архивы

**Кириллица в ZIP без флага `0x800` ломается на Windows.**

### Проверка

**«Страница отдаёт 200» не значит «работает».** Обе поломки
вёрстки проходили все 46 проверок и были видны только на
скриншотах браузера. Скриншоты важнее зелёного теста.

**Сначала проверь сам проверяющий скрипт на заведомо правильном
файле, потом верь его выводу.** Ошибка в самом скрипте выглядит
ровно так же, как ошибка в проекте.

**«Искал и не нашёл» — не факт.** Ограничение глубины поиска
даёт молчаливое «нет», а файл лежит уровнем глубже. Искать надо
без ограничений.

## 23. Чего нельзя менять

Список вещей, которые выглядят как можно убрать, но убирать их
нельзя — проверено, что без них перестаёт работать.

| Что | Почему нельзя |
|---|---|
| `LOGIN_URL = "login"` в `settings.py` | без неё `@login_required` отправляет гостя на `/accounts/login/`, которого нет, и получается 404 вместо страницы входа |
| `CommonMiddleware` | делает редирект `/login` → `/login/`; без него тело POST теряется и форма не срабатывает |
| Отключение CSRF | прямо написано в тексте задания, дважды. С включённой защитой проверяющая система не сможет отправить ни одну форму |
| Проверка владельца в `applications` | `filter(..., user=request.user)` — единственное, что не даёт удалить чужую заявку |
| `set_password` в `seed.py` | иначе пароль администратора не совпадёт с тем, что вводится при входе |
| Все 17 `data-testid` | ищет проверяющая система; нет хоть одного — задание не засчитано |
| Значения цветов и размеров из 2.1 | заданы в задании буквально |
| Шрифт PT Sans из `static/fonts/` | проверяется как шрифт проекта; системного PT Sans на машине нет |
| Зависимость `psycopg[binary]` | без драйвера Django не подключится к базе, и упадут все четыре модуля |
| Запуск PostgreSQL до `migrate` | иначе `Connection refused` на самом первом шаге |
| Значения в `DATABASES` и в `DSN` | они должны совпадать с тем, что вводится в проверяющую программу: роль `conf2027`, пароль `conf2027`, хост `127.0.0.1`, порт `5432` |
| `row_factory` в `api.py` | без него psycopg отдаёт строку обычным tuple, и обращение `order["id"]` падает с `TypeError` |
| Строка `DSN` в `api.py` | в ней имя выданной базы; при другой базе программа не подключится |

Дополнительно: `project_1.zip` обязан содержать папку `.git`,
потому что задание 1.6 проверяет историю коммитов.

**Резервная копия.** Файл базы копировать нельзя — данные
лежат у сервера. Перед сносом базы обязательно
`bash tools/backup_db.sh`, откат — `bash tools/restore_db.sh`.

## 24. Чего пока нет

Честный список. Всё это за рамками задания, поэтому не сделано.

| Нет | Почему |
|---|---|
| Телефон в базе | телефон обязателен как поле формы регистрации, но хранить и показывать его задание не требует |
| Справочник помещений | задание говорит «введя его название в поле» — подсказки не требуются |
| Дата и время заявки | нигде не показываются по заданию |
| Поиск по тексту в панели | задание просит только фильтр по статусу |
| Восстановление пароля | не упоминается |
| Страница профиля | не упоминается |
| Исходник дизайна (`.penpot`) | делается в графическом редакторе на рабочем месте, не кодом |
| Django admin | панель администратора своя, из обычного представления |

**Корень `/` отдаёт 302** на `/applications/` или `/login/`.
Это нормально: страницы по КИМ ровно пять, а `/` — технический
переход.
