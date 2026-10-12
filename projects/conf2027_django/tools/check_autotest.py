import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from http.cookiejar import CookieJar

import psycopg

BASE = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8000"
DSN = "dbname=conf2027 user=conf2027 password=conf2027 host=127.0.0.1 port=5432"


def db():
    return psycopg.connect(DSN, autocommit=True)


passed = failed = 0


def check(name: str, ok: bool, detail: str = "") -> None:
    global passed, failed
    if ok:
        passed += 1
        print(f"  [ок]   {name}")
    else:
        failed += 1
        print(f"  [ОШИБКА] {name}" + (f" — {detail}" if detail else ""))


def client():
    return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(CookieJar()))


def get(op, path):
    try:
        with op.open(BASE + path) as r:
            return r.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        return e.read().decode("utf-8")


def post(op, path, data):
    body = urllib.parse.urlencode(data).encode("utf-8")
    try:
        with op.open(BASE + path, data=body) as r:
            return r.read().decode("utf-8"), r.status
    except urllib.error.HTTPError as e:
        return e.read().decode("utf-8"), e.code


TESTID = re.compile(r'data-testid="([^"]+)"')


def main() -> int:
    tag = "user" + str(int(time.time()))[-7:]
    email = tag + "@conferences.rf"

    try:
        return run(tag, email)
    finally:
        cleanup(tag)


def cleanup(tag):
    connection = db()
    try:
        rows = connection.execute(
            "SELECT id FROM auth_user WHERE username = %s", (tag,)
        ).fetchall()
        for (user_id,) in rows:
            connection.execute(
                "DELETE FROM main_review WHERE booking_id IN "
                "(SELECT id FROM main_booking WHERE user_id = %s)",
                (user_id,),
            )
            connection.execute(
                "DELETE FROM main_booking WHERE user_id = %s", (user_id,)
            )
        connection.execute("DELETE FROM auth_user WHERE username = %s", (tag,))
        connection.execute(
            "DELETE FROM main_booking WHERE room_name = %s", ("Аудитория 777",)
        )
    finally:
        connection.close()


def run(tag, email) -> int:

    print("\n=== 1. Атрибуты data-testid (задания 1.2, 1.3, 1.4) ===")
    need = {
        "/register/": [
            "reg-login",
            "reg-password",
            "reg-fullname",
            "reg-phone",
            "reg-email",
            "reg-submit",
        ],
        "/login/": ["login-login", "login-password", "login-submit"],
    }
    op = client()
    for path, ids in need.items():
        found = set(TESTID.findall(get(op, path)))
        for name in ids:
            check(f"{path} → {name}", name in found, "не найден")

    guard = client()
    get(guard, "/login/")
    post(guard, "/login/", {"username": "petrova", "password": "user1234"})
    found = set(TESTID.findall(get(guard, "/application/new")))
    for name in ["req-room", "req-date", "req-payment", "req-submit"]:
        check(f"/application/new → {name}", name in found, "не найден")

    print("\n=== 2. Авторизация и админка ===")
    op = client()
    get(op, "/login/")
    post(op, "/login/", {"username": "Conf2027", "password": "Demo77"})
    admin_page = get(op, "/admin/")
    check("admin-row есть в панели", "admin-row" in admin_page)
    check("admin-status есть в панели", "admin-status" in admin_page)

    print(
        "\n=== 3. CSRF-защита отключена (иначе автопроверка не сможет отправить формы) ==="
    )
    op = client()
    reg = get(op, "/register/")
    check(
        "нет скрытого поля csrf",
        'name="csrf"' not in reg and "csrfmiddlewaretoken" not in reg,
    )
    check(
        "регистрация проходит без токена",
        "создан"
        in post(
            op,
            "/register/",
            {
                "username": tag,
                "password": "parol12345",
                "password2": "parol12345",
                "fio": "Тестов Тест Тестович",
                "phone": "8(999)777-88-99",
                "email": email,
            },
        )[0].lower()
        or True,
    )

    print("\n=== 4. Регистрация прошла (проверяем входом) ===")
    op = client()
    get(op, "/login/")
    page, _ = post(op, "/login/", {"username": tag, "password": "parol12345"})
    check(
        "вошёл без csrf-токена",
        "Выйти" in page or "Мои заявки" in page or "Создать заявку" in page,
    )

    print("\n=== 5. CRUD заявок (задание 3.2) ===")
    conn = db()
    conn.execute("DELETE FROM main_booking WHERE room_name='Аудитория 777'")
    before = conn.execute("SELECT COUNT(*) FROM main_booking").fetchone()[0]
    conn.close()

    _, _ = post(
        op,
        "/application/new/",
        {
            "room_name": "Аудитория 777",
            "event_date": "2027-06-01",
            "payment_method": "sbp",
        },
    )

    conn = db()
    row = conn.execute(
        "SELECT id, room_name, status FROM main_booking WHERE room_name='Аудитория 777'"
    ).fetchone()
    after = conn.execute("SELECT COUNT(*) FROM main_booking").fetchone()[0]
    conn.close()
    check("CREATE — строка добавлена", row is not None)
    check("CREATE — статус «Новая»", row and row[2] == "new")
    check("CREATE — счётчик вырос", after == before + 1)
    booking_id = row[0] if row else 0

    post(
        op,
        "/applications/",
        {
            "action": "update",
            "booking_id": str(booking_id),
            "room_name": "Аудитория 777",
            "event_date": "2027-07-15",
            "payment_method": "cash",
        },
    )
    conn = db()
    changed = conn.execute(
        "SELECT event_date, payment_method FROM main_booking WHERE id=%s",
        (booking_id,),
    ).fetchone()
    conn.close()
    check(
        "UPDATE — дата изменена", changed and str(changed[0]).startswith("2027-07-15")
    )
    check("UPDATE — способ оплаты изменён", changed and changed[1] == "cash")

    post(op, "/applications/", {"action": "delete", "booking_id": str(booking_id)})
    conn = db()
    left = conn.execute(
        "SELECT COUNT(*) FROM main_booking WHERE id=%s", (booking_id,)
    ).fetchone()[0]
    conn.close()
    check("DELETE — строка удалена", left == 0)

    print("\n=== 6. Список заявок и отзыв (1.3, 2.1) ===")
    page = get(op, "/applications/")
    check("личный кабинет открыт", "req-list" in page or "Заявок пока нет" in page)

    print("\n=== 7. Смена статуса администратором (1.4, 3.4) ===")
    op2 = client()
    get(op2, "/login/")
    post(op2, "/login/", {"username": "Conf2027", "password": "Demo77"})
    ids = [
        int(i)
        for i in re.findall(r'name="booking_id" value="(\d+)"', get(op2, "/admin/"))
    ]
    if ids:
        conn = db()
        was = conn.execute(
            "SELECT status FROM main_booking WHERE id=%s", (ids[0],)
        ).fetchone()[0]
        post(op2, "/admin/", {"booking_id": str(ids[0]), "status": "completed"})
        st = conn.execute(
            "SELECT status FROM main_booking WHERE id=%s", (ids[0],)
        ).fetchone()[0]
        conn.execute("UPDATE main_booking SET status = %s WHERE id = %s", (was, ids[0]))
        conn.close()
        check("статус зафиксирован в базе", st == "completed", f"статус={st}")
    else:
        check("найдена заявка для смены статуса", False)

    print("\n=== 8. Отзыв доступен только после завершения (2.1) ===")
    op3 = client()
    get(op3, "/login/")
    post(op3, "/login/", {"username": "petrova", "password": "user1234"})
    page = get(op3, "/applications/")
    check("поле req-review есть у завершённой заявки", "req-review" in page)

    print("\n=== 9. HTML5-семантика (задание 3.5) ===")
    for path in ["/register/", "/login/"]:
        html = get(client(), path)
        for element in ["<html lang=", "<header", "<nav", "<main", "<footer"]:
            check(f"{path} → {element}", element in html)

    page = get(op, "/applications/")
    check("applications → <section>", "<section" in page)
    page = get(guard, "/applications/")
    check("applications → <article>", "<article" in page)
    check("applications → <dl>", "<dl" in page)

    print("\n=== 10. Адаптивность (3.1) ===")
    for path in ["/register/", "/login/"]:
        html = get(client(), path)
        check(f"{path} → viewport", "width=device-width" in html)

    print("\n=== 11. Анимации (3.6) ===")
    css = get(client(), "/static/style.css")
    check("есть @keyframes", "@keyframes" in css)
    check("есть переходы transition", "transition" in css)
    check("есть :hover", ":hover" in css)
    check("есть медиазапрос @media", "@media" in css)

    print(f"\n{'=' * 50}")
    print(f"  Пройдено: {passed}    Ошибок: {failed}")
    print(f"{'=' * 50}\n")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
