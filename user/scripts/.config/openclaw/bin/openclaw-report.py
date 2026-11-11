#!/usr/bin/env python3
"""Сводка OpenClaw: markdown в терминал + красивый HTML для браузера."""
import datetime
import html
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys

OPENCLAW = os.environ.get("OPENCLAW_BIN") or shutil.which("openclaw") or str(pathlib.Path.home() / ".local/bin/openclaw")
WORK = pathlib.Path.home() / ".openclaw/workspace"
JOBS = {
    "memory-sync": ("USER.md, MEMORY.md", "ежедневно 04:30"),
    "ops-check": ("ops/status.md", "ежедневно 08:00"),
    "toolwatch": ("research/toolwatch.md", "пятница 09:00"),
    "vps-research": ("research/vps-foreign.md", "понедельник 09:00"),
    "bypass-research": ("research/bypass-2026.md", "среда 09:00"),
}


def run(args, timeout=30):
    try:
        r = subprocess.run([OPENCLAW] + args, capture_output=True,
                           text=True, timeout=timeout)
        return r.stdout
    except Exception:
        return ""


def ts_fmt(ms):
    if not ms:
        return "—"
    try:
        return datetime.datetime.fromtimestamp(ms / 1000).strftime("%d.%m %H:%M")
    except Exception:
        return "—"


def mtime_fmt(rel):
    p = WORK / rel.split(",")[0].strip()
    if not p.exists():
        return "—"
    return datetime.datetime.fromtimestamp(p.stat().st_mtime).strftime("%d.%m %H:%M")


def svc_state(name, user=True):
    cmd = ["systemctl"] + (["--user"] if user else []) + ["is-active", name]
    try:
        return subprocess.run(cmd, capture_output=True, text=True,
                              timeout=10).stdout.strip() or "unknown"
    except Exception:
        return "unknown"


def collect():
    data = {"now": datetime.datetime.now().astimezone().strftime("%d.%m.%Y %H:%M %Z"),
            "gw": svc_state("openclaw-gateway"), "jobs": []}
    data["svc"] = {
        "zapret2": svc_state("zapret2", user=False),
        "usque": svc_state("usque"),
        "usque-http": svc_state("usque-http"),
    }
    data["free_gb"] = shutil.disk_usage("/").free // (1024 ** 3)
    listing = {}
    try:
        listing = {j.get("name"): j for j in json.loads(
            run(["automations", "list", "--json"])).get("jobs", [])}
    except Exception:
        pass

    for name, (rel, when) in JOBS.items():
        j = listing.get(name) or {}
        st = j.get("state") or {}
        entries = []
        jid = j.get("id")
        if jid:
            try:
                entries = json.loads(run(["automations", "runs", jid, "--json"])).get("entries") or []
            except Exception:
                entries = []
        entry = entries[0] if entries else {}
        summary = (entry.get("summary") or "").strip()
        summary_ts = entry.get("ts")
        note = ""
        if not summary:
            for e in entries[1:]:
                if (e.get("summary") or "").strip():
                    summary = e["summary"].strip()
                    summary_ts = e.get("ts")
                    note = "последняя удачная"
                    break
        data["jobs"].append({
            "name": name, "when": when, "rel": rel,
            "last": ts_fmt(st.get("lastRunAtMs")),
            "next": ts_fmt(st.get("nextRunAtMs") or j.get("nextRunAtMs")),
            "status": st.get("lastRunStatus") or st.get("lastStatus") or "—",
            "summary": summary,
            "summary_time": ts_fmt(summary_ts),
            "summary_note": note,
            "file_time": mtime_fmt(rel),
        })
    return data


def render_md(data):
    out = ["# OpenClaw — сводка", "",
           f"Обновлено: **{data['now']}** · шлюз: **{data['gw']}**",
           f"Сейчас: zapret2={data['svc']['zapret2']}, usque={data['svc']['usque']}, "
           f"usque-http={data['svc']['usque-http']}, свободно на /: {data['free_gb']} ГБ",
           "", "## Задачи", "",
           "| Задача | Когда | Последний запуск | Статус | Файл результата |",
           "|---|---|---|---|---|"]
    for j in data["jobs"]:
        out.append(f"| {j['name']} | {j['when']} | {j['last']} | {j['status']} | `{j['rel']}` |")
    out += ["", "## Последние результаты", ""]
    for j in data["jobs"]:
        head = f"### {j['name']} — {j['summary_time']} ({j['status']})"
        if j.get("summary_note"):
            head += f" · {j['summary_note']}"
        out += [head, ""]
        out.append(j["summary"] or "_Сводки нет; смотри файл результата._")
        out += ["", f"Файл: `~/.openclaw/workspace/{j['rel'].split(',')[0].strip()}`"
                    f" (обновлён {j['file_time']})", ""]
    return "\n".join(out).rstrip() + "\n"


def md_inline(s):
    s = html.escape(s)
    s = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", s)
    s = re.sub(r"`([^`]+)`", r"<code>\1</code>", s)
    s = re.sub(r"\[([^\]]+)\]\((https?://[^)]+)\)", r'<a href="\2">\1</a>', s)
    s = re.sub(r'(?<!href=")(https?://[^\s<"]+)', r'<a href="\1">\1</a>', s)
    return s


def render_html(data):
    up = {"ok": "ok", "error": "err", "skipped": "idle"}

    def job_pane(j):
        cls = up.get(j["status"], "idle")
        body = md_inline(j["summary"]) if j["summary"] else "<i>Сводки нет — открой файл результата.</i>"
        link = "/" + j["rel"].split(",")[0].strip()
        note = f' · {j["summary_note"]}' if j.get("summary_note") else ""
        return f"""
    <section class="pane" id="j-{j['name']}">
      <div class="phead">
        <h1>{html.escape(j['name'])}</h1>
        <span class="badge {cls}">{html.escape(j['status'])}</span>
      </div>
      <div class="kpis">
        <div class="kpi"><span>Расписание</span><b>{html.escape(j['when'])}</b></div>
        <div class="kpi"><span>Последний запуск</span><b>{j['last']}</b></div>
        <div class="kpi"><span>Следующий</span><b>{j.get('next') or '—'}</b></div>
        <div class="kpi"><span>Файл</span><b>{j['file_time']}</b></div>
      </div>
      <div class="meta">Результат: <a href="{link}">{html.escape(j['rel'])}</a>{html.escape(note)}</div>
      <div class="body-text">{body}</div>
    </section>"""

    panes = "".join(job_pane(j) for j in data["jobs"])

    nav_jobs = "".join(
        f'<a href="#j-{j["name"]}"><span class="nm">{html.escape(j["name"])}</span>'
        f'<span class="dot {up.get(j["status"], "idle")}"></span></a>'
        for j in data["jobs"])

    return PAGE_HEAD + f"""
<aside class="side">
  <div class="brand">OpenClaw<em>панель</em></div>
  <div class="sstat"><b>Шлюз</b> {data['gw']} · <b>Диск</b> {data['free_gb']} ГБ</div>
  <nav>
    <div class="navlabel">Задачи</div>
    {nav_jobs}
    <div class="navlabel">Проверка</div>
    <a href="#check"><span class="nm">Аудит автоматизаций</span></a>
    <a href="#timeouts"><span class="nm">Зависания и время</span></a>
    <div class="navlabel">Инструменты</div>
    <a href="#tools-have"><span class="nm">Что уже стоит</span></a>
    <a href="#tools-miss"><span class="nm">Что добавить</span></a>
    <a href="#tools-new"><span class="nm">Новые под агента</span></a>
    <a href="#tools-low"><span class="nm">Низкий уровень</span></a>
    <div class="navlabel">Правила</div>
    <a href="#rules"><span class="nm">Как чинить</span></a>
  </nav>
  <div class="sfoot">обновление 120 с · <code>ocreport</code></div>
</aside>
<main class="main">{panes}
{INSTRUCTION_PANES}
</main>
<script>
(function() {{
  var panes = [].slice.call(document.querySelectorAll('.pane'));
  if (!panes.length) return;
  function show() {{
    var h = location.hash.replace('#', '');
    var f = panes.filter(function (p) {{ return p.id === h; }})[0] || panes[0];
    panes.forEach(function (p) {{ p.classList.toggle('on', p === f); }});
    var links = [].slice.call(document.querySelectorAll('nav a'));
    links.forEach(function (a) {{ a.classList.toggle('on', a.getAttribute('href') === '#' + f.id); }});
    document.querySelector('.main').scrollTop = 0;
  }}
  window.addEventListener('hashchange', show);
  show();
}})();
</script>
</body></html>"""


PAGE_HEAD = """<!doctype html>
<html lang="ru"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="refresh" content="120">
<title>OpenClaw — панель</title>
<style>
:root{--bg:#0f1017;--panel:#161823;--card:#1b1d2a;--line:#272a3a;--text:#e2e0f0;
--muted:#8b88a8;--accent:#c4a7e7;--ok:#8fd6c0;--err:#f07a94;--warn:#f6c177;--idle:#5f6278}
*{box-sizing:border-box}
html,body{height:100%}
body{margin:0;background:var(--bg);color:var(--text);overflow:hidden;
font:13.5px/1.55 -apple-system,"Segoe UI",Roboto,"Noto Sans",sans-serif}
code{background:#0c0d14;padding:1px 5px;border-radius:4px;font-size:12px;color:#cdb6e8}
a{color:var(--accent);text-decoration:none}
a:hover{text-decoration:underline}
.app,.side,.main{height:100%}
body>aside.side{position:fixed;inset:0 auto 0 0;width:246px;background:var(--panel);
border-right:1px solid var(--line);display:flex;flex-direction:column;padding:16px 12px;overflow:auto}
.brand{font-size:19px;font-weight:700;letter-spacing:-.02em;margin-bottom:2px}
.brand em{display:block;font-style:normal;font-size:11px;font-weight:500;
color:var(--muted);letter-spacing:.08em;text-transform:uppercase;margin-top:2px}
.sstat{font-size:11.5px;color:var(--muted);margin:10px 0 14px;line-height:1.6}
.sstat b{color:var(--text);font-weight:600}
nav{display:flex;flex-direction:column;gap:1px}
.navlabel{font-size:10.5px;text-transform:uppercase;letter-spacing:.09em;
color:var(--idle);margin:14px 0 5px 8px;font-weight:600}
nav a{display:flex;align-items:center;justify-content:space-between;gap:8px;
padding:6px 9px;border-radius:7px;color:var(--text);font-size:13px;border:1px solid transparent}
nav a:hover{background:#1e2130;text-decoration:none}
nav a.on{background:#232642;border-color:#3a3e63;color:#fff}
.nm{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.dot{width:7px;height:7px;border-radius:50%;flex:0 0 7px}
.dot.ok{background:var(--ok)}.dot.err{background:var(--err)}
.dot.idle{background:var(--idle)}
.sfoot{margin-top:auto;padding-top:14px;font-size:11px;color:var(--idle);line-height:1.7}
main.main{margin-left:246px;overflow:auto;padding:22px 26px 40px}
.pane{display:none;max-width:1180px}
.pane.on{display:block}
.phead{display:flex;align-items:center;gap:12px;margin-bottom:14px}
.phead h1{font-size:22px;margin:0;letter-spacing:-.02em}
h2{font-size:15px;margin:22px 0 8px;color:#f0eeff}
h3{font-size:13.5px;margin:16px 0 6px;color:#d9d5f0}
p{margin:8px 0}
.badge{font-size:11px;padding:3px 9px;border-radius:999px;font-weight:700;text-transform:uppercase;letter-spacing:.05em}
.badge.ok{background:#17342e;color:var(--ok)}
.badge.err{background:#3a1723;color:var(--err)}
.badge.idle{background:#23263a;color:var(--muted)}
.kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:8px;margin-bottom:12px}
.kpi{background:var(--card);border:1px solid var(--line);border-radius:9px;padding:9px 11px}
.kpi span{display:block;font-size:10.5px;text-transform:uppercase;letter-spacing:.07em;color:var(--idle);margin-bottom:2px}
.kpi b{font-size:14px;font-weight:600}
.meta{font-size:12px;color:var(--muted);margin-bottom:12px}
.body-text{background:var(--card);border:1px solid var(--line);border-radius:11px;
padding:14px 16px;white-space:pre-wrap;font-size:13px;max-height:calc(100vh - 300px);overflow:auto}
table{width:100%;border-collapse:collapse;margin:10px 0 4px;font-size:12.5px}
th,td{text-align:left;padding:6px 9px;border-bottom:1px solid var(--line);vertical-align:top}
th{color:var(--muted);font-weight:600;font-size:11px;text-transform:uppercase;letter-spacing:.06em}
tbody tr:hover{background:#1e2130}
td.k{color:var(--text);font-weight:600;white-space:nowrap}
.t-ok{color:var(--ok);font-weight:600}.t-err{color:var(--err);font-weight:600}
.t-warn{color:var(--warn);font-weight:600}.t-idle{color:var(--muted)}
.cols{display:grid;grid-template-columns:1fr 1fr;gap:16px}
@media(max-width:1100px){.cols{grid-template-columns:1fr}}
.box{background:var(--card);border:1px solid var(--line);border-radius:11px;padding:13px 15px;margin:10px 0}
.box.warn{border-color:#4a3a1e;background:#241d10}
.box.err{border-color:#4a1f2c;background:#241216}
.box.ok{border-color:#1d4038;background:#12211e}
.box h3{margin-top:0}
ul{margin:6px 0 6px 18px;padding:0}
li{margin:3px 0}
.tag{display:inline-block;font-size:10.5px;padding:1px 6px;border-radius:4px;
background:#232642;color:#a9a4cc;margin-left:6px;letter-spacing:.03em}
</style></head><body>
"""


INSTRUCTION_PANES = """
    <section class="pane" id="check">
      <div class="phead"><h1>Аудит автоматизаций</h1><span class="badge idle">срез 11.11 12:40</span></div>
      <p>Всего задач: <b>7</b> (5 рабочих + heartbeat + промоушен памяти). Расписания и статусы сверены с планировщиком Gateway, вывод — с файлами на диске.</p>
      <table>
        <thead><tr><th>Задача</th><th>Расписание</th><th>Последний запуск</th><th>Длит.</th><th>Итог</th></tr></thead>
        <tbody>
          <tr><td class="k">memory-sync</td><td>ежедн. 04:30</td><td>11.11 04:40</td><td>8 мин 20 с</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">ops-check</td><td>ежедн. 08:00</td><td>11.11 09:03</td><td>2 мин 56 с</td><td class="t-warn">ok, но опоздал на 63 мин</td></tr>
          <tr><td class="k">toolwatch</td><td>пт 09:00</td><td>06.11 09:23</td><td>1 мин 09 с</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">vps-research</td><td>пн 09:00</td><td>09.11 10:15</td><td>20 мин 21 с</td><td class="t-warn">ok, очень долго</td></tr>
          <tr><td class="k">bypass-research</td><td>ср 09:00</td><td>11.11 09:09</td><td>6 мин 18 с</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">Memory Dreaming</td><td>ежедн. 03:00</td><td>11.11 03:00</td><td>—</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">heartbeat</td><td>каждые 30 мин</td><td>11.11 09:06</td><td>0.3 с</td><td class="t-idle">skipped</td></tr>
        </tbody>
      </table>

      <h2>Что действительно сломано</h2>

      <div class="box err">
        <h3>1. Heartbeat мёртв — 278 пропусков подряд</h3>
        <p>Файл <code>~/.openclaw/workspace/HEARTBEAT.md</code> отсутствует. Каждые 30 минут задача завершается со
        статусом <code>skipped / empty-heartbeat-file</code>. Это <b>не авария</b>: пустой heartbeat-файл — штатный способ
        выключить проактивные проверки. Но следствие серьёзное — <b>агент сам ничего не проверяет</b>: ни почту, ни
        календарь, ни состояние системы. Всё, что происходит, происходит только по cron или когда ты напишешь.</p>
        <p>Решение: либо создать файл с чек-листом (тогда +1 запуск модели каждые 30 мин), либо удалить саму задачу
        <code>heartbeat-main</code>, чтобы не копить ложные «failed». Сейчас — ни то, ни другое.</p>
      </div>

      <div class="box err">
        <h3>2. DASHBOARD.html затирался каждые 5 минут</h3>
        <p>Страницу собирает <code>openclaw-report.py</code>, а вызывает его <code>openclaw-maintenance.timer</code>
        каждые 2 минуты (сам HTML — раз в 5 минут). Любая правка файла руками жила максимум 5 минут.
        Поэтому вёрстка перенесена <b>в генератор</b>: <code>/etc/nixos/user/scripts/.config/openclaw/bin/openclaw-report.py</code>.
        Бэкап старой версии лежит рядом.</p>
      </div>

      <div class="box warn">
        <h3>3. Все задачи запускаются с <code>toolsAllow: ["*"]</code></h3>
        <p>Полный доступ ко всем инструментам, включая exec и запись. Для «прочитай и запиши отчёт» это избыточно:
        любая ошибка модели в фоновом прогоне может тронуть систему. Минимум — ограничить до
        <code>exec, read, write, web_search, web_fetch</code>.</p>
      </div>

      <div class="box warn">
        <h3>4. Нет ни одного <code>failureAlert</code></h3>
        <p>Порог по умолчанию — 2 подряд неудачи. Но при выключенном ноутбуке уведомление отправить некуда,
        а «тихое» падение никто не заметит. Стоит явно указать маршрут в Telegram.</p>
      </div>

      <div class="box warn">
        <h3>5. vps-research идёт 20 минут</h3>
        <p>1221 с на прогон — в 12 раз дольше остальных. При сне ноутбука такой прогон почти гарантированно
        рвётся. Разумно разбить на два прохода или сократить список провайдеров до 4–5.</p>
      </div>

      <h2>Что в порядке</h2>
      <ul>
        <li>Ни одной потери результата: все пять рабочих задач пишут файлы, файлы свежие (кроме toolwatch — он недельный).</li>
        <li>Догон пропусков работает: <code>openclaw-maintenance.py</code> поднимает упавшие прогоны (в логе видно <code>trigger ... expected=...</code> и повтор).</li>
        <li>Telegram-уведомления живы: <code>notified ... telegram=sent</code> в каждом запуске, последнее — 11.11 09:12.</li>
        <li>Десктопные уведомления тоже: <code>notify-send</code> на месте, dbus активен.</li>
      </ul>
    </section>

    <section class="pane" id="timeouts">
      <div class="phead"><h1>Зависания и время</h1><span class="badge err">корневая причина</span></div>
      <p>Главная причина «странного» времени запусков — <b>сон ноутбука</b>. Gateway живёт в user-сессии: при
      suspend процесс замирает, таймеры не тикают, а после пробуждения срабатывает догон. За неделю — 11 таких эпизодов.</p>
      <table>
        <thead><tr><th>Когда</th><th>Пауза</th><th>Что было</th></tr></thead>
        <tbody>
          <tr><td class="k">05.11 09:02</td><td>3 ч 23 мин</td><td>ночной сон</td></tr>
          <tr><td class="k">05.11 17:57</td><td>1 ч 07 мин</td><td>крышка / простой</td></tr>
          <tr><td class="k">05.11 21:21</td><td>1 ч 07 мин</td><td>простой</td></tr>
          <tr><td class="k">06.11 09:15</td><td>2 ч 54 мин</td><td>ночной сон</td></tr>
          <tr><td class="k">06.11 21:35</td><td>4 ч 53 мин</td><td>вечерний сон</td></tr>
          <tr><td class="k">09.11 09:30</td><td>4 ч 04 мин</td><td>ночной сон</td></tr>
          <tr><td class="k">09.11 20:09</td><td>5 ч 25 мин</td><td>самый долгий</td></tr>
          <tr><td class="k">10.11 09:22</td><td>3 ч 39 мин</td><td>ночной сон</td></tr>
          <tr><td class="k">10.11 10:02</td><td>16 мин</td><td>короткий</td></tr>
          <tr><td class="k">10.11 16:06</td><td>1 ч 24 мин</td><td>перед перезагрузкой</td></tr>
          <tr><td class="k">11.11 09:03</td><td>2 ч 35 мин</td><td>сон 06:28 → 09:03</td></tr>
        </tbody>
      </table>
      <p>Отсюда и «опоздания»: ops-check по расписанию в 08:00 физически не мог стартовать — ноутбук спал до 09:03.
      Задача не падала, она ждала пробуждения.</p>
      <div class="box">
        <h3>Три способа убрать дрожание времени</h3>
        <ul>
          <li><b>Принять как есть.</b> Догон уже работает, данные не теряются. Минус — время в отчётах плавает.</li>
          <li><b>Не спать в окне задач.</b> <code>systemd-inhibit --what=sleep</code> на 03:50–09:30. Плюс — точность. Минус — ноутбук не спит, расход батареи.</li>
          <li><b>Вынести Gateway на VPS.</b> Радикально: расписания перестают зависеть от крышки. Это ровно та задача, которую ты уже исследовал по РФ-хостингу.</li>
        </ul>
      </div>
      <div class="box warn">
        <h3>Побочный эффект: своп</h3>
        <p>Gateway держит ~1.1 ГБ RSS при 6.7 ГБ всего; в ops-check отмечено 3 ГБ занятого swap при swappiness=100.
        На таком объёме это главный кандидат на «подвисания» даже без сна. Лечится <code>earlyoom</code> или
        <code>MemoryMax</code> на юните (см. «Низкий уровень»).</p>
      </div>
    </section>

    <section class="pane" id="tools-have">
      <div class="phead"><h1>Что уже стоит</h1><span class="badge ok">проверено 11.11</span></div>
      <p>Проверка через <code>command -v</code> в текущей сессии. Всё ниже — реально в PATH, не «должно быть».</p>
      <div class="cols">
        <div>
          <h3>Поиск и файлы</h3>
          <table><tbody>
            <tr><td class="k">rg</td><td class="t-ok">есть</td><td>текстовый поиск</td></tr>
            <tr><td class="k">fd</td><td class="t-ok">есть</td><td>поиск файлов</td></tr>
            <tr><td class="k">fzf</td><td class="t-ok">есть</td><td>интерактивный выбор</td></tr>
            <tr><td class="k">zoxide</td><td class="t-ok">есть</td><td>умный cd</td></tr>
            <tr><td class="k">bat</td><td class="t-ok">есть</td><td>чтение с подсветкой</td></tr>
            <tr><td class="k">glow</td><td class="t-ok">есть</td><td>markdown в терминале</td></tr>
            <tr><td class="k">dust / dua</td><td class="t-ok">есть</td><td>размеры папок</td></tr>
            <tr><td class="k">ctags</td><td class="t-ok">есть</td><td>индекс символов</td></tr>
          </tbody></table>
        </div>
        <div>
          <h3>Данные и документы</h3>
          <table><tbody>
            <tr><td class="k">jq</td><td class="t-ok">есть</td><td>JSON</td></tr>
            <tr><td class="k">sqlite3</td><td class="t-ok">есть</td><td>локальные БД, FTS5</td></tr>
            <tr><td class="k">pandoc</td><td class="t-ok">есть</td><td>конвертация документов</td></tr>
            <tr><td class="k">pdftotext</td><td class="t-ok">есть</td><td>PDF → текст</td></tr>
            <tr><td class="k">tesseract</td><td class="t-ok">есть</td><td>OCR (когда зрение не тянет)</td></tr>
            <tr><td class="k">ffmpeg / yt-dlp</td><td class="t-ok">есть</td><td>медиа</td></tr>
            <tr><td class="k">gh / lazygit</td><td class="t-ok">есть</td><td>GitHub и git</td></tr>
          </tbody></table>
        </div>
        <div>
          <h3>Среда</h3>
          <table><tbody>
            <tr><td class="k">tmux / zellij</td><td class="t-ok">есть</td><td>мультиплексирование</td></tr>
            <tr><td class="k">nu / uv / direnv</td><td class="t-ok">есть</td><td>shell, Python, окружения</td></tr>
            <tr><td class="k">btop</td><td class="t-ok">есть</td><td>мониторинг</td></tr>
            <tr><td class="k">atuin</td><td class="t-ok">есть</td><td>история команд</td></tr>
            <tr><td class="k">strace</td><td class="t-ok">есть</td><td>системные вызовы</td></tr>
            <tr><td class="k">zramctl</td><td class="t-ok">есть</td><td>zram 5.4 ГБ zstd</td></tr>
            <tr><td class="k">notify-send</td><td class="t-ok">есть</td><td>десктоп-уведомления</td></tr>
          </tbody></table>
        </div>
        <div>
          <h3>Ловушка, о которой стоит помнить</h3>
          <div class="box err">
            <p><code>sg</code> в PATH — это <b>/run/wrappers/bin/sg</b>, setuid-обёртка shadow-utils
            («switch group»), а не ast-grep. Если поставить ast-grep, он тоже хочет имя <code>sg</code> —
            получишь конфликт имён и непонятные ошибки.</p>
            <p>Безопасный путь: ставить ast-grep и вызывать полный путь, либо дать алиас
            <code>ast-grep</code> → <code>ast-grep</code> (бинарь называется <code>ast-grep</code>, а <code>sg</code> — просто короткий симлинк).</p>
          </div>
        </div>
      </div>
    </section>

    <section class="pane" id="tools-miss">
      <div class="phead"><h1>Что добавить</h1><span class="badge warn">приоритет</span></div>
      <p>Все имена проверены через <code>nix eval nixpkgs#&lt;name&gt;.name</code> — пакет существует и ставится одной строкой.
      Порядок — по реальной пользе для агента, а не по популярности.</p>
      <table>
        <thead><tr><th>Пакет</th><th>Версия</th><th>Зачем агенту</th><th>Приоритет</th></tr></thead>
        <tbody>
          <tr><td class="k">ast-grep</td><td>0.51.0</td><td>Поиск и правка по <b>структуре кода</b>, а не по регулярке. Главный пробел: без него агент грепает текст и промахивается на переименованиях и вложенности.</td><td class="t-err">высокий</td></tr>
          <tr><td class="k">delta</td><td>0.20.1</td><td>Человекочитаемый diff. Когда агент правит файл, ты видишь смысл, а не звёздочки.</td><td class="t-err">высокий</td></tr>
          <tr><td class="k">difftastic</td><td>0.72.0</td><td>Структурный diff (по AST). Ловит «изменилось одно, а сломалось другое».</td><td class="t-warn">средний</td></tr>
          <tr><td class="k">yq</td><td>3.4.3</td><td>YAML/JSON из одной команды. NixOS-конфиги и compose — сплошь YAML.</td><td class="t-err">высокий</td></tr>
          <tr><td class="k">xh</td><td>0.26.3</td><td>HTTP-клиент с человеческим выводом и подсветкой. Быстрее, чем curl + jq вручную.</td><td class="t-warn">средний</td></tr>
          <tr><td class="k">earlyoom</td><td>1.9.0</td><td>Убивает жирный процесс вместо зависания системы. Прямое лекарство от свопа на 6.7 ГБ.</td><td class="t-err">высокий</td></tr>
          <tr><td class="k">bubblewrap</td><td>0.12.0</td><td>Песочница для недоверенного кода. Аналог того, чем закрыт Claude Code.</td><td class="t-warn">средний</td></tr>
          <tr><td class="k">just</td><td>1.59.0</td><td>Именованные команды в <code>justfile</code> вместо заучивания длинных строк.</td><td class="t-warn">средний</td></tr>
          <tr><td class="k">hyperfine</td><td>2.0.0</td><td>Замер «до/после» с прогревом и статистикой. Без него оптимизация — вера.</td><td class="t-warn">средний</td></tr>
          <tr><td class="k">tokei</td><td>15.0.0</td><td>Быстрая статистика кода: языки, строки, комментарии.</td><td class="t-idle">низкий</td></tr>
          <tr><td class="k">taplo</td><td>0.10.0</td><td>TOML: формат, линт, LSP. Cargo.toml и конфиги.</td><td class="t-idle">низкий</td></tr>
          <tr><td class="k">csvlens</td><td>0.13.0</td><td>Просмотр CSV в терминале. Выгрузки, таблицы, отчёты.</td><td class="t-idle">низкий</td></tr>
          <tr><td class="k">htmlq</td><td>0.4.0</td><td>CSS-селекторы по HTML. Когда web_fetch отдал грязный текст.</td><td class="t-idle">низкий</td></tr>
          <tr><td class="k">sd</td><td>1.1.0</td><td>Замена sed с предсказуемым синтаксисом. Меньше шансов испортить файл.</td><td class="t-idle">низкий</td></tr>
          <tr><td class="k">procs</td><td>0.14.12</td><td>Понятный <code>ps</code>: дерево, порты, CPU.</td><td class="t-idle">низкий</td></tr>
          <tr><td class="k">semgrep</td><td>1.180.0</td><td>Правила безопасности по коду. Дополняет ast-grep там, где нужен линт, а не поиск.</td><td class="t-idle">низкий</td></tr>
          <tr><td class="k">bpftrace</td><td>0.27.1</td><td>Трассировка ядра одной строкой. Для «почему тормозит» без пересборки.</td><td class="t-idle">низкий</td></tr>
        </tbody>
      </table>
      <div class="box ok">
        <h3>Минимальный набор, который даст максимум</h3>
        <p><code>ast-grep</code>, <code>delta</code>, <code>yq</code>, <code>earlyoom</code>. Четыре пакета закрывают
        четыре разных класса проблем: структурный поиск, читаемый diff, работа с YAML, устойчивость к OOM.</p>
      </div>
    </section>

    <section class="pane" id="tools-new">
      <div class="phead"><h1>Новые под агента</h1><span class="badge idle">2026</span></div>
      <p>Класс инструментов, который появился именно под LLM-агентов: они экономят <b>токены</b> и дают
      <b>семантику</b> вместо простого текста. Это не «ещё одна утилита», а другой способ смотреть на код.</p>

      <h2>Семантическая навигация</h2>
      <table>
        <thead><tr><th>Подход</th><th>Что даёт</th><th>Цена</th></tr></thead>
        <tbody>
          <tr><td class="k">tree-sitter индекс</td><td>Агент видит символы и связи, не читая файлы целиком. Экономия токенов кратная.</td><td>Нужен индекс; устаревает при правках</td></tr>
          <tr><td class="k">LSP-серверы</td><td>Переход к определению, все ссылки, типы. То, чего не умеет ни grep, ни tree-sitter.</td><td>Процесс на язык, память, запуск</td></tr>
          <tr><td class="k">agent-lsp (MCP)</td><td>Один процесс роутит .go/.ts/.py по нужному серверу; ответы в сжатом формате — заявлено до 30–84% меньше токенов.</td><td>Молодой проект, надо проверять самому</td></tr>
          <tr><td class="k">serena / cclsp</td><td>Готовые MCP-обёртки над LSP с символами и рефакторингом.</td><td>Зависит от качества сервера языка</td></tr>
        </tbody>
      </table>
      <div class="box warn">
        <p>Важная граница: tree-sitter понимает <b>синтаксис</b>, но не разрешает реэкспорты, алиасы и цепочки типов.
        Для «где реально объявлено» нужен LSP. Обе вещи дополняют друг друга, а не заменяют.</p>
      </div>

      <h2>Экономия контекста</h2>
      <div class="cols">
        <div class="box">
          <h3>Что реально работает</h3>
          <ul>
            <li><b>Индекс вместо чтения.</b> Сначала символы, потом точечное чтение диапазона строк.</li>
            <li><b>Сжатые ответы.</b> Табличный или GCF-формат вместо раздутого JSON.</li>
            <li><b>Дедуп в сессии.</b> Один и тот же файл не перечитывается дважды.</li>
            <li><b>Ограничение вывода.</b> <code>head</code>/<code>--max-count</code> на каждом поиске.</li>
          </ul>
        </div>
        <div class="box">
          <h3>Что звучит красиво, но не стоит времени</h3>
          <ul>
            <li>«Граф знаний по репозиторию» — на маленьких проектах дороже, чем польза.</li>
            <li>Своя векторная БД для памяти, когда есть SQLite FTS5.</li>
            <li>Ещё один агент-оркестратор поверх уже работающего.</li>
          </ul>
        </div>
      </div>

      <h2>Что из этого стоит твоего времени</h2>
      <div class="box ok">
        <ul>
          <li><b>ast-grep</b> — единственный инструмент из списка, который закрывает реальный пробел уже сегодня и ставится за минуту.</li>
          <li><b>SQLite FTS5</b> для поиска по памяти вместо грепа по markdown. Уже есть <code>sqlite3</code>, дополнительно ничего не нужно.</li>
          <li><b>LSP</b> — только если начнёшь вести крупный проект (PixelFM на Rust — кандидат). Для скриптов и заметок избыточно.</li>
        </ul>
      </div>
    </section>

    <section class="pane" id="tools-low">
      <div class="phead"><h1>Низкий уровень</h1><span class="badge warn">оптимизация</span></div>
      <p>То, что не ставится пакетом, а настраивается. Здесь самый большой выигрыш на твоём железе: 6.7 ГБ RAM,
      238 ГБ диска, Gateway на 1.1 ГБ.</p>

      <h2>Память и зависания</h2>
      <table>
        <thead><tr><th>Мера</th><th>Что делает</th><th>Эффект</th></tr></thead>
        <tbody>
          <tr><td class="k">earlyoom</td><td>Убивает самый жирный процесс при нехватке памяти</td><td>Система не встаёт колом, страдает один процесс</td></tr>
          <tr><td class="k">MemoryMax на юните</td><td><code>systemctl --user set-property openclaw-gateway.service MemoryMax=1500M</code></td><td>Gateway не съест всю память; при перерасходе — рестарт, а не своп</td></tr>
          <tr><td class="k">swappiness</td><td>Сейчас 100 при 3 ГБ занятого swap</td><td>Снижение до 10–20 убирает «задумчивость» при пробуждении</td></tr>
          <tr><td class="k">zram</td><td>Уже включён: 5.4 ГБ zstd</td><td>Ничего не делать — работает</td></tr>
        </tbody>
      </table>

      <h2>Расписания</h2>
      <table>
        <thead><tr><th>Мера</th><th>Зачем</th></tr></thead>
        <tbody>
          <tr><td class="k">Persistent=true</td><td>Догнать пропущенное после выключения. У maintenance есть, у <code>openclaw-gateway-restart.timer</code> — <b>нет</b>.</td></tr>
          <tr><td class="k">systemd-inhibit</td><td>Не спать в окне 03:50–09:30, если нужна точность.</td></tr>
          <tr><td class="k">script-payload вместо agentTurn</td><td>Когда решение принимает скрипт, модель не нужна вовсе: ноль токенов на «нечего делать».</td></tr>
          <tr><td class="k">trigger вместо опроса</td><td>Проверка условия без модели; модель просыпается только на срабатывание.</td></tr>
        </tbody>
      </table>

      <h2>Изоляция и диагностика</h2>
      <table>
        <thead><tr><th>Инструмент</th><th>Применение</th></tr></thead>
        <tbody>
          <tr><td class="k">bubblewrap</td><td>Запуск чужого кода без доступа к <code>$HOME</code>: <code>bwrap --ro-bind / / --tmpfs /home …</code></td></tr>
          <tr><td class="k">strace</td><td>Уже есть. «Почему процесс висит» — <code>strace -f -p PID</code>.</td></tr>
          <tr><td class="k">bpftrace</td><td>Агрегаты по ядру без остановки процесса.</td></tr>
          <tr><td class="k">sqlite3 + FTS5</td><td>Полнотекстовый поиск по памяти и логам вместо грепа по файлам.</td></tr>
        </tbody>
      </table>
      <div class="box">
        <h3>Порядок, если делать по одному</h3>
        <p>1) <code>earlyoom</code> — снимает риск полного зависания. 2) <code>swappiness=20</code> — убирает лаг после сна.
        3) <code>MemoryMax</code> на Gateway — страховка. 4) <code>Persistent=true</code> на restart-таймер — догон.
        Всё остальное — уже тонкая настройка.</p>
      </div>
    </section>

    <section class="pane" id="rules">
      <div class="phead"><h1>Как чинить</h1><span class="badge idle">правила</span></div>

      <h2>Где что лежит</h2>
      <table>
        <thead><tr><th>Что</th><th>Путь</th><th>Правится?</th></tr></thead>
        <tbody>
          <tr><td class="k">Генератор панели</td><td><code>/etc/nixos/user/scripts/.config/openclaw/bin/openclaw-report.py</code></td><td class="t-ok">да</td></tr>
          <tr><td class="k">Драйвер обслуживания</td><td><code>…/bin/openclaw-maintenance.py</code></td><td class="t-ok">да</td></tr>
          <tr><td class="k">Симлинки в state</td><td><code>~/.local/state/opencode/openclaw-*.py</code></td><td class="t-err">нет — это ссылки</td></tr>
          <tr><td class="k">Сам DASHBOARD.html</td><td><code>~/.openclaw/workspace/DASHBOARD.html</code></td><td class="t-err">нет — перезапишется</td></tr>
          <tr><td class="k">Настройки задач</td><td>планировщик Gateway (<code>automations</code>)</td><td class="t-ok">да, через инструмент</td></tr>
        </tbody>
      </table>
      <div class="box err">
        <p><b>Главное правило:</b> правки в <code>~/.local/state/opencode/</code> и в сам HTML бесполезны.
        Файлы там — симлинки на репозиторий <code>/etc/nixos</code>, а HTML пересобирается раз в 5 минут.
        Менять надо источник, затем <code>ocreport --write</code>.</p>
      </div>

      <h2>Порядок правки</h2>
      <ul>
        <li><b>1.</b> Бэкап рядом с файлом: <code>cp -a file file.bak-$(date +%Y%m%d-%H%M%S)</code>.</li>
        <li><b>2.</b> Правка в <code>/etc/nixos/user/scripts/…</code>.</li>
        <li><b>3.</b> Проверка синтаксиса: <code>python3 -c "import ast;ast.parse(open(f).read())"</code>.</li>
        <li><b>4.</b> Пересборка панели: <code>ocreport --write</code>.</li>
        <li><b>5.</b> Проверка в браузере: <code>http://127.0.0.1:8089/</code>.</li>
        <li><b>6.</b> Коммит в <code>/etc/nixos</code>, иначе правка потеряется при следующем <code>nixos-rebuild</code>.</li>
      </ul>

      <h2>Что не делать</h2>
      <div class="box warn">
        <ul>
          <li>Не перезапускать Gateway ради проверки задачи — есть <code>automations run</code>.</li>
          <li>Не ставить <code>toolsAllow: ["*"]</code> новым задачам по инерции.</li>
          <li>Не править <code>openclaw-maintenance-state.json</code> руками: там кэш, он перезапишется.</li>
          <li>Не плодить таймеры: один <code>openclaw-maintenance.timer</code> уже делает три работы.</li>
        </ul>
      </div>

      <h2>Проверка, что всё живо</h2>
      <table>
        <thead><tr><th>Проверка</th><th>Команда</th></tr></thead>
        <tbody>
          <tr><td class="k">Задачи</td><td><code>openclaw automations list</code></td></tr>
          <tr><td class="k">История</td><td><code>openclaw automations runs &lt;jobId&gt;</code></td></tr>
          <tr><td class="k">Принудительный прогон</td><td><code>openclaw automations run &lt;jobId&gt; --force</code></td></tr>
          <tr><td class="k">Обслуживание</td><td><code>tail -30 ~/.local/state/opencode/openclaw-maintenance.log</code></td></tr>
          <tr><td class="k">Таймеры</td><td><code>systemctl --user list-timers --all</code></td></tr>
          <tr><td class="k">Панель</td><td><code>curl -s -o /dev/null -w '%{http_code}' 127.0.0.1:8089</code></td></tr>
        </tbody>
      </table>
    </section>
"""


def main():
    data = collect()
    md = render_md(data)
    if "--write" in sys.argv:
        md_path = WORK / "DASHBOARD.md"
        html_path = WORK / "DASHBOARD.html"
        md_path.write_text(md, encoding="utf-8")
        html_path.write_text(render_html(data), encoding="utf-8")
        print(md_path)
        print(html_path)
    else:
        print(md)


if __name__ == "__main__":
    main()
