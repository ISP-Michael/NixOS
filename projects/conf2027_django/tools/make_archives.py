"""Собирает три архива, которые требует КИМ.

  project_1.zip  задание 1.6 — папка проекта вместе с репозиторием .git
  layout_2.zip   задание 2.1 — макеты и всё, на что они ссылаются
  project_3.zip  задание 3.7 — папка проекта с диаграммой базы

Собирается модулем zipfile, а не командой zip: только он ставит флаг
UTF-8 (бит 0x800) в заголовке имени, без него файлы с кириллицей на
Windows распаковываются «кракозябрами».

Запуск: python tools/make_archives.py [куда]
"""

import pathlib
import sys
import zipfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
NAME = "conf2027_django"

SKIP_DIRS = {".venv", "backups", "__pycache__", ".git"}
SKIP_NAMES = {".DS_Store"}
SKIP_SUFFIX = {".pyc", ".zip", ".log"}
DESIGN_SUFFIX = {".penpot", ".fig", ".psd", ".xcf", ".afdesign"}

# Папки, которые упаковываются в архив макетов: сами макеты плюс всё,
# на что они ссылаются. Без static/ макеты откроются без стилей.
LAYOUT_DIRS = ["mobile", "static"]


def keep(path, with_git):
    parts = set(path.relative_to(ROOT).parts)
    if parts & (SKIP_DIRS - {".git"}):
        return False
    if ".git" in parts and not with_git:
        return False
    if path.name in SKIP_NAMES:
        return False
    return path.suffix not in SKIP_SUFFIX


def collect(dirs, with_git):
    """Список файлов относительно корня проекта."""
    files = []
    for rel in dirs:
        base = ROOT / rel if rel != "." else ROOT
        if base.is_file():
            if keep(base, with_git):
                files.append(base)
            continue
        for path in sorted(base.rglob("*")):
            if path.is_file() and keep(path, with_git):
                files.append(path)
    return files


def design_files():
    return [
        p
        for p in sorted(ROOT.rglob("*"))
        if p.is_file() and p.suffix.lower() in DESIGN_SUFFIX
    ]


def write(archive, files, prefix):
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for path in files:
            name = path.relative_to(ROOT).as_posix()
            z.write(path, f"{prefix}/{name}" if prefix else name)
    return archive


def report(archive, files, prefix, probes):
    size = archive.stat().st_size
    with zipfile.ZipFile(archive) as z:
        names = {i.filename for i in z.infolist()}
        broken = [
            i.filename
            for i in z.infolist()
            if not i.flag_bits & 0x800 and not i.filename.isascii()
        ]

    def inside(rel):
        return f"{prefix}/{rel}" if prefix else rel

    print(f"  {archive.name:16} {len(files):5} файлов  {size // 1024:5} КБ")
    if prefix:
        print(f"  {'':16} внутри: {prefix}/")
    print(f"  {'':16} UTF-8 флаг: {'НАРУШЕНИЕ ' + str(broken) if broken else 'ок'}")
    for probe in probes:
        mark = "есть" if inside(probe) in names else "НЕТ "
        print(f"  {'':16} {mark}: {probe}")


def main():
    out = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT
    out.mkdir(parents=True, exist_ok=True)

    print("Сборка архивов")
    print()

    with_git = collect(["."], with_git=True)
    write(out / "project_1.zip", with_git, NAME)
    report(
        out / "project_1.zip",
        with_git,
        NAME,
        [
            ".git/HEAD",
            ".git/config",
            "manage.py",
            "shop_db.sql",
            "main/models.py",
            "api.py",
        ],
    )

    print()
    layout = collect(LAYOUT_DIRS, with_git=False)
    layout += [p for p in design_files() if p not in layout]
    write(out / "layout_2.zip", layout, "")
    report(
        out / "layout_2.zip",
        layout,
        "",
        [
            "mobile/login.html",
            "mobile/register.html",
            "mobile/new-request.html",
            "mobile/requests.html",
            "mobile/admin.html",
            "static/style.css",
            "static/fonts/PTSans-Regular.ttf",
        ],
    )

    print()
    without_git = collect(["."], with_git=False)
    write(out / "project_3.zip", without_git, NAME)
    report(
        out / "project_3.zip",
        without_git,
        NAME,
        [
            "manage.py",
            "docs/ER-diagramma.png",
            "docs/ER-diagramma.svg",
            "shop_db.sql",
            "api.py",
        ],
    )

    print()
    designs = design_files()
    if designs:
        print(f"  исходник дизайна вложен: {', '.join(p.name for p in designs)}")
    else:
        print("  ВНИМАНИЕ: исходника дизайна нет (.penpot, .fig, .psd, .xcf,")
        print("  .afdesign). Задание 2.1 требует его приложить. Сделать можно")
        print("  только графическим редактором на рабочем месте — кодом не")
        print("  закрывается. Положи файл рядом с макетами и пересобери.")


if __name__ == "__main__":
    main()
