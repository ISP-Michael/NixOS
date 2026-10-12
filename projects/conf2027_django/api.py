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
