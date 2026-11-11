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


def _job_pane(j):
    up = {"ok": "ok", "error": "err", "skipped": "idle"}
    cls = up.get(j["status"], "idle")
    body = md_inline(j["summary"]) if j["summary"] else "<i>Сводки нет — открой файл результата.</i>"
    link = "/" + j["rel"].split(",")[0].strip()
    note = f'<span class="note">· {html.escape(j["summary_note"])}</span>' if j.get("summary_note") else ""
    return f"""
    <section class="pane" id="j-{j['name']}">
      <div class="phead">
        <div class="ptitle"><h1>{html.escape(j['name'])}</h1>
          <span class="sub">результат задачи</span></div>
        <span class="pill {cls}">{html.escape(j['status'])}</span>
      </div>
      <div class="kpis">
        <div class="kpi"><span>Расписание</span><b>{html.escape(j['when'])}</b></div>
        <div class="kpi"><span>Последний запуск</span><b>{j['last']}</b></div>
        <div class="kpi"><span>Следующий</span><b>{j.get('next') or '—'}</b></div>
        <div class="kpi"><span>Файл обновлён</span><b>{j['file_time']}</b></div>
      </div>
      <div class="meta">Файл: <a href="{link}">{html.escape(j['rel'])}</a>{note}</div>
      <div class="summary fill">{body}</div>
    </section>"""


def render_html(data):
    up = {"ok": "ok", "error": "err", "skipped": "idle"}
    panes = "".join(_job_pane(j) for j in data["jobs"])

    nav_jobs = "".join(
        f'<a href="#j-{j["name"]}"><span class="nm">{html.escape(j["name"])}</span>'
        f'<span class="dot {up.get(j["status"], "idle")}"></span></a>'
        for j in data["jobs"])

    return PAGE_HEAD + f"""
<aside class="side">
  <div class="brand">OpenClaw<span>панель состояния</span></div>
  <div class="sstat">
    <div><span>Шлюз</span><b>{data['gw']}</b></div>
    <div><span>Диск</span><b>{data['free_gb']} ГБ</b></div>
  </div>
  <nav>
    <div class="navlabel">Результаты</div>
    {nav_jobs}
    <div class="navlabel">Диагностика</div>
    <a href="#check"><span class="nm">Аудит автоматизаций</span></a>
    <a href="#timeouts"><span class="nm">Зависания и время</span></a>
    <div class="navlabel">Инструменты</div>
    <a href="#tools-have"><span class="nm">Что уже стоит</span></a>
    <a href="#tools-miss"><span class="nm">Что добавить</span><span class="cnt">17</span></a>
    <a href="#tools-new"><span class="nm">Новые под агента</span></a>
    <a href="#tools-low"><span class="nm">Низкий уровень</span></a>
    <div class="navlabel">Правила</div>
    <a href="#rules"><span class="nm">Как чинить</span></a>
  </nav>
  <div class="sfoot"><span>{data['now']}</span>автообновление 120 с</div>
</aside>
<main class="main">{panes}
{INSTRUCTION_PANES}
</main>
<script>
(function () {{
  var panes = [].slice.call(document.querySelectorAll('.pane'));
  var links = [].slice.call(document.querySelectorAll('nav a'));
  if (!panes.length) return;
  function show() {{
    var h = location.hash.replace('#', '');
    var f = panes.filter(function (p) {{ return p.id === h; }})[0] || panes[0];
    panes.forEach(function (p) {{ p.classList.toggle('on', p === f); }});
    links.forEach(function (a) {{
      a.classList.toggle('on', a.getAttribute('href') === '#' + f.id);
    }});
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
:root{
--bg:#0c0d13; --side:#11131c; --card:#161925; --card2:#1b1f2e; --line:#252a3b;
--text:#e7e5f4; --dim:#9b97ba; --faint:#666a84;
--accent:#b79cf0; --ok:#7fd7c4; --err:#f2789a; --warn:#f5c26b; --idle:#5a5e78;
}
*{box-sizing:border-box}
html,body{height:100%}
body{margin:0;background:var(--bg);color:var(--text);overflow:hidden;
font:14px/1.55 -apple-system,"Segoe UI",Roboto,"Noto Sans",sans-serif}
code{background:#08090e;padding:1px 5px;border-radius:4px;font-size:11.5px;color:#c9b3f2}
a{color:var(--accent);text-decoration:none}
a:hover{text-decoration:underline}

aside.side{position:fixed;left:0;top:0;bottom:0;width:248px;background:var(--side);
border-right:1px solid var(--line);display:flex;flex-direction:column;
padding:18px 12px 12px}
.brand{font-size:20px;font-weight:700;letter-spacing:-.025em;padding:0 8px}
.brand span{display:block;font-size:10px;font-weight:500;color:var(--faint);
letter-spacing:.11em;text-transform:uppercase;margin-top:3px}
.sstat{margin:14px 8px 4px;padding:9px 10px;background:var(--card);border:1px solid var(--line);
border-radius:8px;display:flex;flex-direction:column;gap:3px;font-size:11px}
.sstat div{display:flex;justify-content:space-between;gap:8px}
.sstat span{color:var(--faint)}
.sstat b{font-weight:600;color:var(--text)}
nav{display:flex;flex-direction:column;gap:1px;margin-top:6px;overflow:auto}
.navlabel{font-size:9.5px;text-transform:uppercase;letter-spacing:.11em;color:#4d5169;
margin:13px 0 4px 9px;font-weight:700}
nav a{display:flex;align-items:center;justify-content:space-between;gap:8px;
padding:7px 10px;border-radius:7px;color:#c9c6dd;font-size:13px;border-left:2px solid transparent}
nav a:hover{background:#191d2b;text-decoration:none;color:#fff}
nav a.on{background:#20243a;border-left-color:var(--accent);color:#fff;font-weight:600}
.nm{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.cnt{font-size:10px;color:var(--faint);background:#1b1f2e;padding:0 5px;border-radius:9px}
.dot{width:6px;height:6px;border-radius:50%;flex:0 0 6px}
.dot.ok{background:var(--ok)} .dot.err{background:var(--err)} .dot.idle{background:var(--idle)}
.sfoot{margin-top:auto;padding:12px 9px 2px;font-size:10px;color:#4d5169;line-height:1.6;
border-top:1px solid var(--line)}
.sfoot span{display:block;color:var(--dim);font-size:10.5px}

main.main{position:fixed;left:248px;right:0;top:0;bottom:0;padding:16px 20px 14px;
display:flex;flex-direction:column}
.pane{display:none;flex-direction:column;gap:10px;flex:1;min-height:0}
.pane.on{display:flex}
.pane>*{flex:0 0 auto}
.pane>.fill{flex:1 1 auto;min-height:0}
.pane>.summary.fill{display:block}
.phead{display:flex;align-items:center;justify-content:space-between;gap:14px;
padding-bottom:9px;border-bottom:1px solid var(--line)}
.ptitle{display:flex;align-items:baseline;gap:11px;min-width:0}
h1{font-size:25px;margin:0;letter-spacing:-.025em;font-weight:700}
.sub{font-size:11.5px;color:var(--faint);letter-spacing:.06em;text-transform:uppercase}
h2{font-size:12.5px;margin:0 0 7px;color:#cfcbe6;letter-spacing:.04em;
text-transform:uppercase;font-weight:700;display:flex;align-items:center;gap:7px}
h2::before{content:"";width:2px;height:11px;background:var(--accent);border-radius:1px}
h3{font-size:13.5px;margin:0 0 7px;color:#e0dcf2;font-weight:650}
p{margin:6px 0}
.pill{font-size:10px;padding:3px 10px;border-radius:11px;font-weight:700;
text-transform:uppercase;letter-spacing:.08em;flex:0 0 auto}
.pill.ok{background:#122e29;color:var(--ok)}
.pill.err{background:#33131e;color:var(--err)}
.pill.idle{background:#1c2033;color:var(--dim)}
.pill.warn{background:#33260f;color:var(--warn)}

.kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:8px}
.kpi{background:var(--card);border:1px solid var(--line);border-radius:9px;padding:11px 13px}
.kpi span{display:block;font-size:10px;text-transform:uppercase;letter-spacing:.09em;
color:var(--faint);margin-bottom:2px}
.kpi b{font-size:15px;font-weight:600}
.meta{font-size:12.5px;color:var(--dim)}
.note{color:var(--warn);margin-left:6px}
.summary{background:var(--card);border:1px solid var(--line);border-radius:10px;
padding:16px 20px;font-size:14px;column-count:2;column-gap:30px;column-fill:balance;
line-height:1.68;overflow:hidden}
.summary p{margin:0 0 7px}
.summary .h{font-weight:700;color:#f3f0ff;break-after:avoid}

.grid2{display:grid;grid-template-columns:1fr 1fr;gap:12px;align-content:start;min-height:0}
.grid3{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;align-content:start;min-height:0}
.grid2.fill,.grid3.fill{flex:1 1 auto;overflow:hidden;align-items:stretch;align-content:stretch;grid-auto-rows:minmax(0,1fr)}
.grid2.fill>div,.grid3.fill>div{display:flex;flex-direction:column;gap:12px;min-height:0}
.grid2.fill>div::after,.grid3.fill>div::after{content:"";flex:1 1 auto;min-height:0}
.grid2.fill>div>*,.grid3.fill>div>*{flex:0 0 auto}
.grid2.fill>div>.tbl,.grid3.fill>div>.tbl{min-height:0}
.grid2.fill>div>.box,.grid3.fill>div>.box{flex:0 0 auto;min-height:0}

.grid2.fill>div>.box.mt,.grid3.fill>div>.box.mt{margin-top:0}
.tbl:last-child>table{height:100%}
.tbl>table>tbody>tr>td{vertical-align:top}
@media(max-width:1180px){.grid2,.grid3{grid-template-columns:1fr}}

.tbl{border:1px solid var(--line);border-radius:9px;overflow:hidden;background:var(--card)}
table{width:100%;border-collapse:collapse;font-size:13px}
th{text-align:left;padding:9px 11px;background:#1a1e2c;color:var(--faint);font-size:9.5px;
text-transform:uppercase;letter-spacing:.08em;font-weight:700;border-bottom:1px solid var(--line)}
td{padding:8px 11px;border-bottom:1px solid #1e2232;vertical-align:top}
tr:last-child td{border-bottom:none}
tbody tr:hover{background:#1b1f2e}
td.k{font-weight:600;color:#f0edff;white-space:nowrap}
.t-ok{color:var(--ok);font-weight:600} .t-err{color:var(--err);font-weight:600}
.t-warn{color:var(--warn);font-weight:600} .t-idle{color:var(--faint)}

.box{background:var(--card);border:1px solid var(--line);border-left:2px solid var(--line);
border-radius:8px;padding:13px 16px}
.box+.box{margin-top:8px}
.box.ok{border-left-color:var(--ok)}
.box.warn{border-left-color:var(--warn)}
.box.err{border-left-color:var(--err)}
.box h3{font-size:12.5px;margin-bottom:4px}
.box p{margin:5px 0;font-size:13px;color:#cfcbe2}
ul{margin:4px 0;padding-left:16px}
li{margin:4px 0;font-size:13px;color:#cfcbe2}
b.hl{color:#f2eeff}
.tag{display:inline-block;font-size:10px;padding:1px 6px;border-radius:4px;
background:#232842;color:#a49fce;margin-left:6px;letter-spacing:.04em;font-weight:600}
.big{font-size:15px;font-weight:700;letter-spacing:-.01em}
.mono{font-family:ui-monospace,"JetBrains Mono",monospace;font-size:11px}
</style></head><body>
"""


INSTRUCTION_PANES = """
    <section class="pane" id="check">
      <div class="phead">
        <div class="ptitle"><h1>Аудит автоматизаций</h1>
          <span class="sub">7 задач · срез 11.11</span></div>
        <span class="pill warn">2 поломки</span>
      </div>
      <div class="grid2 fill">
        <div>
          <h2>Расписания и итоги</h2>
          <div class="tbl"><table>
            <thead><tr><th>Задача</th><th>Когда</th><th>Последний</th><th>Длит.</th><th>Итог</th></tr></thead>
            <tbody>
              <tr><td class="k">memory-sync</td><td>ежедн. 04:30</td><td>11.11 04:40</td><td>8м 20с</td><td class="t-ok">ok</td></tr>
              <tr><td class="k">ops-check</td><td>ежедн. 08:00</td><td>11.11 09:03</td><td>2м 56с</td><td class="t-warn">опоздал 63м</td></tr>
              <tr><td class="k">toolwatch</td><td>пт 09:00</td><td>06.11 09:23</td><td>1м 09с</td><td class="t-ok">ok</td></tr>
              <tr><td class="k">vps-research</td><td>пн 09:00</td><td>09.11 10:15</td><td>20м 21с</td><td class="t-warn">очень долго</td></tr>
              <tr><td class="k">bypass-research</td><td>ср 09:00</td><td>11.11 09:09</td><td>6м 18с</td><td class="t-ok">ok</td></tr>
              <tr><td class="k">Memory Dreaming</td><td>ежедн. 03:00</td><td>11.11 03:00</td><td>—</td><td class="t-ok">ok</td></tr>
              <tr><td class="k">heartbeat</td><td>каждые 30 мин</td><td>11.11 09:06</td><td>0.3с</td><td class="t-idle">skipped</td></tr>
            </tbody>
          </table></div>
          <div class="box ok" style="margin-top:10px">
            <h3>Что в порядке</h3>
            <ul>
              <li>Ни одной потери результата — все пять задач пишут файлы, файлы свежие.</li>
              <li>Догон пропусков работает: в логе видно <code>trigger ... expected=...</code> и повтор.</li>
              <li>Telegram жив: <code>telegram=sent</code> в каждом запуске, последнее 11.11 09:12.</li>
              <li>Десктоп тоже: <code>notify-send</code> на месте, dbus активен.</li>
            </ul>
          </div>
        </div>
        <div>
          <h2>Что сломано</h2>
          <div class="box err">
            <h3>1 · Heartbeat мёртв — 278 пропусков</h3>
            <p>Файла <code>HEARTBEAT.md</code> нет, каждый прогон — <code>skipped / empty-heartbeat-file</code>.
            Пустой файл это штатный способ выключить, но следствие: <b class="hl">агент сам ничего не проверяет</b> —
            ни почту, ни календарь, ни систему.</p>
          </div>
          <div class="box err">
            <h3>2 · Панель затиралась каждые 5 минут</h3>
            <p>HTML собирает <code>openclaw-report.py</code>, его дёргает таймер обслуживания. Правки руками жили
            максимум 5 минут. Вёрстка перенесена в генератор, бэкап старой версии лежит рядом.</p>
          </div>
          <div class="box warn">
            <h3>3 · У всех задач <code>toolsAllow: ["*"]</code></h3>
            <p>Полный доступ, включая exec и запись. Для «прочитай и запиши отчёт» избыточно.</p>
          </div>
          <div class="box warn">
            <h3>4 · Ни одного <code>failureAlert</code></h3>
            <p>Тихие падения никто не заметит — уведомление отправлять некуда.</p>
          </div>
          <div class="box warn">
            <h3>5 · vps-research идёт 20 минут</h3>
            <p>1221 с — в 12 раз дольше остальных. При сне ноутбука такой прогон почти гарантированно рвётся.</p>
          </div>
        </div>
      </div>
    </section>

    <section class="pane" id="timeouts">
      <div class="phead">
        <div class="ptitle"><h1>Зависания и время</h1>
          <span class="sub">корневая причина</span></div>
        <span class="pill err">11 пауз за неделю</span>
      </div>
      <div class="grid2 fill">
        <div>
          <h2>Эпизоды сна</h2>
          <div class="tbl"><table>
            <thead><tr><th>Когда</th><th>Пауза</th><th>Причина</th></tr></thead>
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
          </table></div>
        </div>
        <div>
          <h2>Почему время плавает</h2>
          <div class="box">
            <p>Gateway живёт в user-сессии. При suspend процесс замирает, таймеры не тикают, после пробуждения
            срабатывает догон. «Опоздание на 63 минуты» у ops-check — не поломка: ноутбук спал с 06:28 до 09:03.</p>
          </div>
          <h2 style="margin-top:12px">Три способа убрать дрожание</h2>
          <div class="tbl"><table>
            <thead><tr><th>Способ</th><th>Плюс</th><th>Минус</th></tr></thead>
            <tbody>
              <tr><td class="k">Принять как есть</td><td>догон уже работает, данные не теряются</td><td>время в отчётах плавает</td></tr>
              <tr><td class="k">Не спать 03:50–09:30</td><td>точность расписаний</td><td>батарея не спит</td></tr>
              <tr><td class="k">Вынести на VPS</td><td>радикально: не зависит от крышки</td><td>нужен сервер и туннель</td></tr>
            </tbody>
          </table></div>
          <div class="box warn" style="margin-top:10px">
            <h3>Побочный эффект — своп</h3>
            <p>Gateway держит ~1.1 ГБ при 6.7 ГБ всего; в ops-check отмечено 3 ГБ занятого swap при
            <code>swappiness=100</code>. Это второй кандидат на подвисания даже без сна.</p>
          </div>
        </div>
      </div>
    </section>

    <section class="pane" id="tools-have">
      <div class="phead">
        <div class="ptitle"><h1>Что уже стоит</h1>
          <span class="sub">проверено через command -v</span></div>
        <span class="pill ok">в PATH</span>
      </div>
      <div class="grid3 fill">
        <div>
          <h2>Поиск и файлы</h2>
          <div class="tbl"><table><tbody>
            <tr><td class="k">rg</td><td class="t-ok">есть</td><td>текстовый поиск</td></tr>
            <tr><td class="k">fd</td><td class="t-ok">есть</td><td>поиск файлов</td></tr>
            <tr><td class="k">fzf</td><td class="t-ok">есть</td><td>интерактивный выбор</td></tr>
            <tr><td class="k">zoxide</td><td class="t-ok">есть</td><td>умный cd</td></tr>
            <tr><td class="k">bat</td><td class="t-ok">есть</td><td>чтение с подсветкой</td></tr>
            <tr><td class="k">glow</td><td class="t-ok">есть</td><td>markdown в терминале</td></tr>
            <tr><td class="k">dust / dua</td><td class="t-ok">есть</td><td>размеры папок</td></tr>
            <tr><td class="k">ctags</td><td class="t-ok">есть</td><td>индекс символов</td></tr>
          </tbody></table></div>
          <h2 style="margin-top:12px">Данные</h2>
          <div class="tbl"><table><tbody>
            <tr><td class="k">jq</td><td class="t-ok">есть</td><td>JSON</td></tr>
            <tr><td class="k">sqlite3</td><td class="t-ok">есть</td><td>БД, FTS5</td></tr>
            <tr><td class="k">pandoc</td><td class="t-ok">есть</td><td>конвертация</td></tr>
            <tr><td class="k">pdftotext</td><td class="t-ok">есть</td><td>PDF → текст</td></tr>
            <tr><td class="k">tesseract</td><td class="t-ok">есть</td><td>OCR</td></tr>
          </tbody></table></div>
        </div>
        <div>
          <h2>Среда</h2>
          <div class="tbl"><table><tbody>
            <tr><td class="k">tmux / zellij</td><td class="t-ok">есть</td><td>мультиплексоры</td></tr>
            <tr><td class="k">nu / uv</td><td class="t-ok">есть</td><td>shell, Python</td></tr>
            <tr><td class="k">direnv</td><td class="t-ok">есть</td><td>окружения</td></tr>
            <tr><td class="k">btop</td><td class="t-ok">есть</td><td>мониторинг</td></tr>
            <tr><td class="k">atuin</td><td class="t-ok">есть</td><td>история команд</td></tr>
            <tr><td class="k">strace</td><td class="t-ok">есть</td><td>сисколлы</td></tr>
            <tr><td class="k">zramctl</td><td class="t-ok">есть</td><td>zram 5.4 ГБ</td></tr>
            <tr><td class="k">notify-send</td><td class="t-ok">есть</td><td>уведомления</td></tr>
            <tr><td class="k">gh / lazygit</td><td class="t-ok">есть</td><td>GitHub, git</td></tr>
            <tr><td class="k">ffmpeg / yt-dlp</td><td class="t-ok">есть</td><td>медиа</td></tr>
          </tbody></table></div>
          <div class="box ok" style="margin-top:12px">
            <h3>Итог</h3>
            <p>База закрыта плотно: поиск, данные, документы, медиа, git, мониторинг. Пробелы не в базе,
            а в слое «структурный код» и «устойчивость к нехватке памяти».</p>
          </div>
        </div>
        <div>
          <h2>Ловушка</h2>
          <div class="box err">
            <h3><code>sg</code> — это не ast-grep</h3>
            <p>В PATH <code>sg</code> — это <code>/run/wrappers/bin/sg</code>, setuid-обёртка shadow-utils
            («switch group»). ast-grep тоже хочет имя <code>sg</code>.</p>
            <p>Получишь конфликт имён и непонятные ошибки. Вызывай бинарь <code>ast-grep</code> напрямую
            или задай алиас.</p>
          </div>
          <h2 style="margin-top:12px">Чего не хватает по классам</h2>
          <div class="tbl"><table><tbody>
            <tr><td class="k">структурный поиск</td><td class="t-err">нет</td><td>ast-grep</td></tr>
            <tr><td class="k">читаемый diff</td><td class="t-err">нет</td><td>delta, difftastic</td></tr>
            <tr><td class="k">YAML/TOML</td><td class="t-err">нет</td><td>yq, taplo</td></tr>
            <tr><td class="k">защита от OOM</td><td class="t-err">нет</td><td>earlyoom</td></tr>
            <tr><td class="k">HTTP-клиент</td><td class="t-warn">частично</td><td>xh</td></tr>
            <tr><td class="k">песочница</td><td class="t-err">нет</td><td>bubblewrap</td></tr>
          </tbody></table></div>
        </div>
      </div>
    </section>

    <section class="pane" id="tools-miss">
      <div class="phead">
        <div class="ptitle"><h1>Что добавить</h1>
          <span class="sub">имена сверены с nixpkgs</span></div>
        <span class="pill warn">4 главных</span>
      </div>
      <div class="grid2 fill" style="flex:0 0 auto">
        <div style="grid-column:1/-1">
          <div class="tbl"><table>
            <thead><tr><th>Пакет</th><th>Версия</th><th>Зачем агенту</th><th>Приоритет</th></tr></thead>
            <tbody>
              <tr><td class="k">ast-grep</td><td class="mono">0.51.0</td><td>Поиск и правка по <b>структуре кода</b>. Без него агент грепает текст и промахивается на переименованиях.</td><td class="t-err">высокий</td></tr>
              <tr><td class="k">delta</td><td class="mono">0.20.1</td><td>Человекочитаемый diff. Видно смысл правки, а не звёздочки.</td><td class="t-err">высокий</td></tr>
              <tr><td class="k">yq</td><td class="mono">3.4.3</td><td>YAML и JSON одной командой. NixOS-конфиги — сплошь YAML.</td><td class="t-err">высокий</td></tr>
              <tr><td class="k">earlyoom</td><td class="mono">1.9.0</td><td>Убивает жирный процесс вместо зависания системы. Лекарство от свопа.</td><td class="t-err">высокий</td></tr>
              <tr><td class="k">difftastic</td><td class="mono">0.72.0</td><td>Структурный diff по AST. Ловит «изменилось одно, сломалось другое».</td><td class="t-warn">средний</td></tr>
              <tr><td class="k">xh</td><td class="mono">0.26.3</td><td>HTTP с подсветкой. Быстрее, чем curl + jq вручную.</td><td class="t-warn">средний</td></tr>
              <tr><td class="k">bubblewrap</td><td class="mono">0.12.0</td><td>Песочница для недоверенного кода.</td><td class="t-warn">средний</td></tr>
              <tr><td class="k">just</td><td class="mono">1.59.0</td><td>Именованные команды вместо заучивания длинных строк.</td><td class="t-warn">средний</td></tr>
              <tr><td class="k">hyperfine</td><td class="mono">2.0.0</td><td>Замер «до/после» с прогревом и статистикой.</td><td class="t-warn">средний</td></tr>
              <tr><td class="k">tokei</td><td class="mono">15.0.0</td><td>Статистика кода: языки, строки, комментарии.</td><td class="t-idle">низкий</td></tr>
              <tr><td class="k">taplo</td><td class="mono">0.10.0</td><td>TOML: формат, линт, LSP.</td><td class="t-idle">низкий</td></tr>
              <tr><td class="k">csvlens</td><td class="mono">0.13.0</td><td>Просмотр CSV в терминале.</td><td class="t-idle">низкий</td></tr>
              <tr><td class="k">htmlq</td><td class="mono">0.4.0</td><td>CSS-селекторы по HTML, когда web_fetch отдал грязь.</td><td class="t-idle">низкий</td></tr>
              <tr><td class="k">sd</td><td class="mono">1.1.0</td><td>Замена sed с предсказуемым синтаксисом.</td><td class="t-idle">низкий</td></tr>
              <tr><td class="k">procs</td><td class="mono">0.14.12</td><td>Понятный ps: дерево, порты, CPU.</td><td class="t-idle">низкий</td></tr>
              <tr><td class="k">semgrep</td><td class="mono">1.180.0</td><td>Правила безопасности по коду.</td><td class="t-idle">низкий</td></tr>
              <tr><td class="k">bpftrace</td><td class="mono">0.27.1</td><td>Трассировка ядра одной строкой.</td><td class="t-idle">низкий</td></tr>
            </tbody>
          </table></div>
        </div>
      </div>
      <div class="box ok" style="margin-top:auto">
        <h3>Минимальный набор с максимальной отдачей</h3>
        <p><code>ast-grep</code> · <code>delta</code> · <code>yq</code> · <code>earlyoom</code> —
        четыре пакета закрывают четыре разных класса проблем: структурный поиск, читаемый diff,
        работа с YAML, устойчивость к OOM.</p>
      </div>
    </section>

    <section class="pane" id="tools-new">
      <div class="phead">
        <div class="ptitle"><h1>Новые под агента</h1>
          <span class="sub">класс 2026 · экономия токенов</span></div>
        <span class="pill idle">семантика</span>
      </div>
      <div class="grid2 fill">
        <div>
          <h2>Семантическая навигация</h2>
          <div class="tbl"><table>
            <thead><tr><th>Подход</th><th>Что даёт</th><th>Цена</th></tr></thead>
            <tbody>
              <tr><td class="k">tree-sitter индекс</td><td>Символы и связи без чтения файлов целиком. Экономия токенов кратная.</td><td>индекс устаревает</td></tr>
              <tr><td class="k">LSP-серверы</td><td>Переход к определению, все ссылки, типы. Чего не умеет ни grep, ни tree-sitter.</td><td>процесс на язык</td></tr>
              <tr><td class="k">agent-lsp</td><td>Один процесс роутит .go/.ts/.py; ответы в сжатом виде — заявлено до 30–84% меньше токенов.</td><td>молодой проект</td></tr>
              <tr><td class="k">serena / cclsp</td><td>Готовые MCP-обёртки над LSP: символы и рефакторинг.</td><td>зависит от сервера</td></tr>
            </tbody>
          </table></div>
          <div class="box warn" style="margin-top:10px">
            <p>Граница: tree-sitter понимает <b>синтаксис</b>, но не разрешает реэкспорты, алиасы и цепочки типов.
            Для «где реально объявлено» нужен LSP. Они дополняют друг друга.</p>
          </div>
        </div>
        <div>
          <h2>Экономия контекста</h2>
          <div class="box ok">
            <h3>Работает</h3>
            <ul>
              <li><b>Индекс вместо чтения.</b> Сначала символы, потом точечный диапазон строк.</li>
              <li><b>Сжатые ответы.</b> Таблица вместо раздутого JSON.</li>
              <li><b>Дедуп в сессии.</b> Файл не перечитывается дважды.</li>
              <li><b>Лимит вывода.</b> <code>--max-count</code> на каждом поиске.</li>
            </ul>
          </div>
          <div class="box err" style="margin-top:8px">
            <h3>Звучит красиво, но не стоит времени</h3>
            <ul>
              <li>«Граф знаний по репозиторию» — на малых проектах дороже пользы.</li>
              <li>Своя векторная БД, когда есть SQLite FTS5.</li>
              <li>Ещё один агент-оркестратор поверх работающего.</li>
            </ul>
          </div>
          <h2 style="margin-top:12px">Что стоит твоего времени</h2>
          <div class="tbl"><table><tbody>
            <tr><td class="k">ast-grep</td><td>Закрывает реальный пробел сегодня, ставится за минуту.</td></tr>
            <tr><td class="k">SQLite FTS5</td><td>Поиск по памяти вместо грепа по markdown. <code>sqlite3</code> уже есть.</td></tr>
            <tr><td class="k">LSP</td><td>Только для крупного проекта (PixelFM на Rust). Для скриптов избыточно.</td></tr>
          </tbody></table></div>
        </div>
      </div>
    </section>

    <section class="pane" id="tools-low">
      <div class="phead">
        <div class="ptitle"><h1>Низкий уровень</h1>
          <span class="sub">6.7 ГБ RAM · 238 ГБ диска</span></div>
        <span class="pill ok">наибольший выигрыш</span>
      </div>
      <div class="grid3 fill" style="flex:0 0 auto">
        <div>
          <h2>Память</h2>
          <div class="tbl"><table>
            <thead><tr><th>Мера</th><th>Эффект</th></tr></thead>
            <tbody>
              <tr><td class="k">earlyoom</td><td>Убивает жирный процесс вместо зависания системы</td></tr>
              <tr><td class="k">MemoryMax на юните</td><td>Gateway не съест память: рестарт вместо свопа</td></tr>
              <tr><td class="k">swappiness 10–20</td><td>Сейчас 100 при 3 ГБ swap — убирает лаг после сна</td></tr>
              <tr><td class="k">zram</td><td>Уже есть: 5.4 ГБ zstd. Не трогать</td></tr>
              <tr><td class="k">MemoryHigh</td><td>Мягкий порог: притормозить процесс до жёсткого убийства</td></tr>
              <tr><td class="k">vm.vfs_cache_pressure</td><td>Меньше 100 — ядро охотнее держит кэш файлов</td></tr>
              <tr><td class="k">OOMScoreAdjust</td><td>Пометить Gateway как «убить первым» или «не трогать»</td></tr>
            </tbody>
          </table></div>
        </div>
        <div>
          <h2>Расписания</h2>
          <div class="tbl"><table>
            <thead><tr><th>Мера</th><th>Зачем</th></tr></thead>
            <tbody>
              <tr><td class="k">Persistent=true</td><td>Догнать пропущенное. У restart-таймера этого нет</td></tr>
              <tr><td class="k">systemd-inhibit</td><td>Не спать в окне 03:50–09:30</td></tr>
              <tr><td class="k">script-payload</td><td>Решение принимает скрипт — модель не нужна</td></tr>
              <tr><td class="k">trigger</td><td>Проверка условия без модели, пробуждение только на срабатывание</td></tr>
              <tr><td class="k">pacing</td><td>Адаптивный интервал: чаще при активности, реже в тишине</td></tr>
              <tr><td class="k">timeoutSeconds</td><td>Жёсткий предел на прогон — зависание не блокирует очередь</td></tr>
              <tr><td class="k">staggerMs</td><td>Разброс старта, чтобы задачи не били в одну секунду</td></tr>
            </tbody>
          </table></div>
        </div>
        <div>
          <h2>Изоляция и диагностика</h2>
          <div class="tbl"><table>
            <thead><tr><th>Инструмент</th><th>Применение</th></tr></thead>
            <tbody>
              <tr><td class="k">bubblewrap</td><td>Чужой код без доступа к <code>$HOME</code></td></tr>
              <tr><td class="k">strace</td><td>«Почему висит» — есть уже сейчас</td></tr>
              <tr><td class="k">bpftrace</td><td>Агрегаты по ядру без остановки процесса</td></tr>
              <tr><td class="k">FTS5</td><td>Полнотекстовый поиск по памяти и логам</td></tr>
              <tr><td class="k">systemd-run --scope</td><td>Разовый запуск в своей cgroup с лимитами</td></tr>
              <tr><td class="k">journalctl -o json</td><td>Логи структурой, а не текстом — сразу в jq</td></tr>
              <tr><td class="k">socat / tcpdump</td><td>Проверить, что реально уходит в сеть</td></tr>
            </tbody>
          </table></div>
        </div>
      </div>
      <div class="box ok" style="margin-top:auto">
        <h3>Порядок, если делать по одному</h3>
        <p><b class="hl">1</b> <code>earlyoom</code> — снимает риск полного зависания ·
        <b class="hl">2</b> <code>swappiness=20</code> — убирает лаг после сна ·
        <b class="hl">3</b> <code>MemoryMax</code> на Gateway — страховка ·
        <b class="hl">4</b> <code>Persistent=true</code> на restart-таймер — догон.
        Остальное — тонкая настройка.</p>
      </div>
    </section>

    <section class="pane" id="rules">
      <div class="phead">
        <div class="ptitle"><h1>Как чинить</h1>
          <span class="sub">чтобы не потерять правку</span></div>
        <span class="pill warn">читать перед правкой</span>
      </div>
      <div class="grid2 fill">
        <div>
          <h2>Где что лежит</h2>
          <div class="tbl"><table>
            <thead><tr><th>Что</th><th>Путь</th><th>Правится</th></tr></thead>
            <tbody>
              <tr><td class="k">Генератор</td><td class="mono">…/openclaw/bin/openclaw-report.py</td><td class="t-ok">да</td></tr>
              <tr><td class="k">Драйвер</td><td class="mono">…/openclaw-maintenance.py</td><td class="t-ok">да</td></tr>
              <tr><td class="k">Симлинки</td><td class="mono">~/.local/state/opencode/*.py</td><td class="t-err">нет</td></tr>
              <tr><td class="k">HTML</td><td class="mono">workspace/DASHBOARD.html</td><td class="t-err">нет</td></tr>
              <tr><td class="k">Задачи</td><td>планировщик Gateway</td><td class="t-ok">да</td></tr>
            </tbody>
          </table></div>
          <div class="box err" style="margin-top:10px">
            <h3>Главное правило</h3>
            <p>Правки в <code>~/.local/state/opencode/</code> и в сам HTML бесполезны: там симлинки на
            <code>/etc/nixos</code>, а HTML пересобирается раз в 5 минут.
            Менять надо источник, затем <code>ocreport --write</code>.</p>
          </div>
          <h2 style="margin-top:12px">Что не делать</h2>
          <div class="box warn">
            <ul>
              <li>Не перезапускать Gateway ради проверки — есть <code>automations run</code>.</li>
              <li>Не ставить <code>toolsAllow: ["*"]</code> по инерции.</li>
              <li>Не править <code>openclaw-maintenance-state.json</code> — это кэш.</li>
              <li>Не плодить таймеры: один уже делает три работы.</li>
            </ul>
          </div>
        </div>
        <div>
          <h2>Порядок правки</h2>
          <div class="tbl"><table><tbody>
            <tr><td class="k">1</td><td>Бэкап рядом с файлом: <code>cp -a file file.bak-$(date +%Y%m%d-%H%M%S)</code></td></tr>
            <tr><td class="k">2</td><td>Правка в <code>/etc/nixos/user/scripts/…</code></td></tr>
            <tr><td class="k">3</td><td>Синтаксис: <code>python3 -c "import ast;ast.parse(open(f).read())"</code></td></tr>
            <tr><td class="k">4</td><td>Пересборка: <code>ocreport --write</code></td></tr>
            <tr><td class="k">5</td><td>Проверка: открыть <code>127.0.0.1:8089</code></td></tr>
            <tr><td class="k">6</td><td>Коммит в <code>/etc/nixos</code>, иначе потеряется при rebuild</td></tr>
          </tbody></table></div>
          <h2 style="margin-top:12px">Проверка, что всё живо</h2>
          <div class="tbl"><table>
            <thead><tr><th>Проверка</th><th>Команда</th></tr></thead>
            <tbody>
              <tr><td class="k">Задачи</td><td><code>openclaw automations list</code></td></tr>
              <tr><td class="k">История</td><td><code>openclaw automations runs &lt;jobId&gt;</code></td></tr>
              <tr><td class="k">Прогон сейчас</td><td><code>openclaw automations run &lt;jobId&gt; --force</code></td></tr>
              <tr><td class="k">Обслуживание</td><td><code>tail -30 ~/.local/state/opencode/openclaw-maintenance.log</code></td></tr>
              <tr><td class="k">Таймеры</td><td><code>systemctl --user list-timers --all</code></td></tr>
              <tr><td class="k">Панель</td><td><code>curl -s -o /dev/null -w '%{http_code}' 127.0.0.1:8089</code></td></tr>
            </tbody>
          </table></div>
        </div>
      </div>
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
