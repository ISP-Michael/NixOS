#!/usr/bin/env python3
"""Сводка OpenClaw: markdown в терминал + красивый HTML для браузера."""
import datetime
import math
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


import math

DURS = {"memory-sync": 500, "ops-check": 176, "toolwatch": 69,
        "vps-research": 1221, "bypass-research": 378}
SLEEP = [("05.11 09:02", 203), ("05.11 17:57", 67), ("05.11 21:21", 67),
         ("06.11 09:15", 174), ("06.11 21:35", 293), ("09.11 09:30", 244),
         ("09.11 20:09", 325), ("10.11 09:22", 219), ("10.11 10:02", 16),
         ("10.11 16:06", 84), ("11.11 09:03", 155)]


def fmt_dur(sec):
    m, s = divmod(int(sec), 60)
    return f"{m}м {s:02d}с" if m else f"{s}с"


def ring(pct, color, size=54, stroke=5):
    r = (size - stroke) / 2
    c = 2 * math.pi * r
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 {size} {size}" class="ring">'
            f'<circle cx="{size/2}" cy="{size/2}" r="{r}" fill="none" '
            f'stroke="#232840" stroke-width="{stroke}"/>'
            f'<circle cx="{size/2}" cy="{size/2}" r="{r}" fill="none" stroke="{color}" '
            f'stroke-width="{stroke}" stroke-linecap="round" '
            f'stroke-dasharray="{c:.1f}" stroke-dashoffset="{c*(1-pct/100):.1f}" '
            f'transform="rotate(-90 {size/2} {size/2})"/></svg>')


DUR_MINI = dict(DURS)
DUR_MAX = max(DURS.values())


# ============ графика ============

def _svg(w, h, body):
    return f'<svg viewBox="0 0 {w} {h}" class="chart">{"".join(body)}</svg>'


def bars_h(items, maxv, w=760, rowh=34, barh=14, lw=190):
    body = []
    h = len(items) * rowh + 10
    for i, (lab, val, col, txt) in enumerate(items):
        y = i * rowh + 6
        bw = max(3.0, (float(val) / (maxv or 1)) * (w - lw - 110))
        body.append(f'<text x="0" y="{y+barh-2}" class="clab">{html.escape(lab)}</text>')
        body.append(f'<rect x="{lw}" y="{y}" width="{w-lw-110}" height="{barh}" rx="6" fill="#1c2133"/>')
        body.append(f'<rect x="{lw}" y="{y}" width="{bw:.1f}" height="{barh}" rx="6" fill="{col}"/>')
        body.append(f'<text x="{lw+bw+12:.0f}" y="{y+barh-2}" class="cval">{html.escape(txt)}</text>')
    return _svg(w, h, body)


def meter(pct, color, label, value, w=760, h=46):
    body = [
        f'<text x="0" y="14" class="clab">{html.escape(label)}</text>',
        f'<text x="{w}" y="14" class="cval" text-anchor="end">{html.escape(value)}</text>',
        f'<rect x="0" y="24" width="{w}" height="12" rx="6" fill="#1c2133"/>',
        f'<rect x="0" y="24" width="{max(4.0, w*pct/100):.1f}" height="12" rx="6" fill="{color}"/>',
    ]
    return _svg(w, h, body)


def sparkline(recent, w=760, h=64, color="#7fd7c4"):
    """Полоса исходов прогонов: слева старые, справа новые."""
    n = len(recent) or 1
    gap = 4
    bw = (w - gap * (n - 1)) / n
    body = [f'<line x1="0" y1="{h-14}" x2="{w}" y2="{h-14}" stroke="#252a3b"/>']
    maxd = max((r["d"] for r in recent), default=1) or 1
    for i, r in enumerate(recent):
        bh = max(6.0, (r["d"] / maxd) * (h - 24))
        x = i * (bw + gap)
        col = "#7fd7c4" if r["s"] == "ok" else "#f2789a"
        body.append(f'<rect x="{x:.1f}" y="{h-14-bh:.1f}" width="{bw:.1f}" '
                    f'height="{bh:.1f}" rx="3" fill="{col}" opacity="0.9"/>')
    return _svg(w, h, body)


def donut(ok, err, w=210, h=210, label="успешных"):
    total = ok + err or 1
    pct = ok / total * 100
    r = 74
    c = 2 * math.pi * r
    cx = cy = w / 2
    body = [
        f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="#2a1d26" stroke-width="22"/>',
        f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="#7fd7c4" stroke-width="22" '
        f'stroke-linecap="round" stroke-dasharray="{c*pct/100:.1f} {c:.1f}" '
        f'transform="rotate(-90 {cx} {cy})"/>',
        f'<text x="{cx}" y="{cy+4}" class="dnum" text-anchor="middle">{pct:.0f}%</text>',
        f'<text x="{cx}" y="{cy+30}" class="dsub" text-anchor="middle">{ok} из {total} {label}</text>',
    ]
    return _svg(w, h, body)


def hbar_pct(pct, color, w=180, h=14):
    body = [
        f'<rect x="0" y="0" width="{w}" height="{h}" rx="7" fill="#1c2133"/>',
        f'<rect x="0" y="0" width="{max(3.0, w*pct/100):.1f}" height="{h}" rx="7" fill="{color}"/>',
    ]
    return _svg(w, h, body)


def steps_html(items):
    rows = []
    for num, title, text, color in items:
        rows.append(
            f'<div class="step"><span class="sn" style="border-color:{color};color:{color}">{num}</span>'
            f'<div><b>{html.escape(title)}</b><span>{html.escape(text)}</span></div></div>')
    return '<div class="steps">' + "".join(rows) + "</div>"


def fmt_dur(ms):
    """Принимает миллисекунды из истории прогонов."""
    sec = int((ms or 0) / 1000)
    m, s = divmod(sec, 60)
    if m >= 60:
        h, m = divmod(m, 60)
        return f"{h}ч {m:02d}м"
    if m:
        return f"{m}м {s:02d}с"
    return f"{s}с"


def details(title, body, cls=""):
    return (f'<details class="det {cls}"><summary>{title}</summary>'
            f'<div class="det-body">{body}</div></details>')


PAGE_HEAD = """<!doctype html>
<html lang="ru"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="refresh" content="180">
<title>OpenClaw — панель</title>
<style>
:root{
--bg:#0c0d13; --side:#11131c; --card:#161925; --card2:#1b1f2e; --line:#252a3b;
--text:#e9e7f5; --dim:#a29ec0; --faint:#6d7189;
--accent:#b79cf0; --ok:#7fd7c4; --err:#f2789a; --warn:#f5c26b; --idle:#5a5e78;
}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--text);
font:15px/1.62 -apple-system,"Segoe UI",Roboto,"Noto Sans",sans-serif;
-webkit-font-smoothing:antialiased}
code{background:#08090e;padding:2px 6px;border-radius:5px;font-size:13px;color:#cbb5f4}
a{color:var(--accent);text-decoration:none}
a:hover{text-decoration:underline}

aside.side{position:fixed;left:0;top:0;bottom:0;width:290px;background:var(--side);
border-right:1px solid var(--line);display:flex;flex-direction:column;
padding:22px 16px 14px;overflow:auto}
.brand{font-size:24px;font-weight:700;letter-spacing:-.02em;padding:0 8px}
.brand span{display:block;font-size:11.5px;font-weight:500;color:var(--faint);
letter-spacing:.12em;text-transform:uppercase;margin-top:4px}
.sstat{margin:16px 6px 6px;padding:12px 13px;background:var(--card);
border:1px solid var(--line);border-radius:10px;display:flex;
flex-direction:column;gap:6px;font-size:13px}
.sstat div{display:flex;justify-content:space-between;gap:8px}
.sstat span{color:var(--faint)}
.sstat b{font-weight:600}
nav{display:flex;flex-direction:column;gap:2px;margin-top:8px}
.navlabel{font-size:11px;text-transform:uppercase;letter-spacing:.13em;
color:#565a75;margin:18px 0 6px 10px;font-weight:700}
nav a{display:flex;align-items:center;justify-content:space-between;gap:8px;
padding:9px 11px;border-radius:8px;color:#cfcce2;font-size:16px;
border-left:3px solid transparent}
nav a:hover{background:#191d2b;text-decoration:none;color:#fff}
nav a.on{background:#20243a;border-left-color:var(--accent);color:#fff;font-weight:600}
.nm{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.cnt{font-size:12px;color:var(--faint);background:#1b1f2e;padding:1px 7px;border-radius:10px}
.dot{width:8px;height:8px;border-radius:50%;flex:0 0 8px}
.dot.ok{background:var(--ok)} .dot.err{background:var(--err)} .dot.idle{background:var(--idle)}
.sfoot{margin-top:auto;padding:16px 10px 2px;font-size:11.5px;color:#565a75;
line-height:1.7;border-top:1px solid var(--line)}
.sfoot span{display:block;color:var(--dim);font-size:12.5px}

main.main{margin-left:290px;padding:30px 34px 70px;min-height:100vh}
.col{max-width:1120px;margin:0 auto}
.pane{display:none}
.pane.on{display:block}

.phead{display:flex;align-items:center;justify-content:space-between;gap:16px;
padding-bottom:14px;margin-bottom:20px;border-bottom:1px solid var(--line)}
.ptitle{display:flex;align-items:baseline;gap:12px;flex-wrap:wrap}
h1{font-size:32px;margin:0;letter-spacing:-.03em;font-weight:700}
.sub{font-size:12.5px;color:var(--faint);letter-spacing:.08em;text-transform:uppercase}
h2{font-size:14px;margin:32px 0 10px;color:#d5d0ee;letter-spacing:.06em;
text-transform:uppercase;font-weight:700;display:flex;align-items:center;gap:9px}
h2::before{content:"";width:3px;height:13px;background:var(--accent);border-radius:2px}
h2:first-child{margin-top:0}
h3{font-size:16px;margin:0 0 8px;color:#f0edfb;font-weight:650}
p{margin:8px 0}
.pill{font-size:11.5px;padding:5px 13px;border-radius:12px;font-weight:700;
text-transform:uppercase;letter-spacing:.09em;white-space:nowrap}
.pill.ok{background:#122e29;color:var(--ok)}
.pill.err{background:#33131e;color:var(--err)}
.pill.idle{background:#1c2033;color:var(--dim)}
.pill.warn{background:#33260f;color:var(--warn)}

.kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));
gap:12px;margin-bottom:16px}
.kpi{background:var(--card);border:1px solid var(--line);border-radius:11px;
padding:14px 16px}
.kpi span{display:block;font-size:11px;text-transform:uppercase;letter-spacing:.1em;
color:var(--faint);margin-bottom:4px}
.kpi b{font-size:17px;font-weight:600}
.meta{font-size:14px;color:var(--dim);margin-bottom:16px}
.note{color:var(--warn);margin-left:8px}
.quiet{color:var(--faint);font-size:14px;margin:6px 0}

.summary{background:var(--card);border:1px solid var(--line);border-radius:14px;
padding:22px 26px;font-size:15px;line-height:1.78}
.summary p{margin:0 0 10px}

.viz{background:var(--card2);border:1px solid var(--line);border-radius:12px;
padding:16px 18px;margin-bottom:16px}
.viz-h{font-size:11.5px;text-transform:uppercase;letter-spacing:.1em;
color:var(--faint);margin-bottom:12px;font-weight:600}
.viz-grid{display:grid;grid-template-columns:240px 1fr;gap:14px;align-items:start}
@media(max-width:820px){.viz-grid{grid-template-columns:1fr}}
.donut-wrap{display:flex;justify-content:center;align-items:center;padding:4px 0}
.chart{width:100%;height:auto;display:block;overflow:visible}
.clab{fill:#a49fc4;font-size:12.5px;font-family:inherit}
.cval{fill:#e9e7f5;font-size:12.5px;font-weight:600;font-family:inherit}
.dnum{fill:#e9e7f5;font-size:26px;font-weight:700;font-family:inherit}
.dsub{fill:#8b87a8;font-size:11.5px;font-family:inherit}

.tbl{border:1px solid var(--line);border-radius:12px;overflow:hidden;background:var(--card)}
table{width:100%;border-collapse:collapse;font-size:14.5px}
th{text-align:left;padding:11px 14px;background:#1a1e2c;color:var(--faint);
font-size:11px;text-transform:uppercase;letter-spacing:.1em;font-weight:700;
border-bottom:1px solid var(--line)}
td{padding:11px 14px;border-bottom:1px solid #1e2232;vertical-align:top}
tr:last-child td{border-bottom:none}
tbody tr:hover{background:#1b1f2e}
td.k{font-weight:600;color:#f2efff;white-space:nowrap}
.t-ok{color:var(--ok);font-weight:600}
.t-err{color:var(--err);font-weight:600}
.t-warn{color:var(--warn);font-weight:600}
.t-idle{color:var(--faint)}

.box{background:var(--card);border:1px solid var(--line);border-left:3px solid var(--line);
border-radius:11px;padding:18px 20px;margin:14px 0}
.box.ok{border-left-color:var(--ok)}
.box.warn{border-left-color:var(--warn)}
.box.err{border-left-color:var(--err)}
.box h3{font-size:16px}
.box p{margin:6px 0;font-size:14.5px;color:#d2cee6}
ul{margin:8px 0;padding-left:22px}
li{margin:6px 0;font-size:14.5px;color:#d2cee6}
b.hl{color:#f6f2ff}
.mono{font-family:ui-monospace,"JetBrains Mono",monospace;font-size:13px}
.split{display:grid;grid-template-columns:1fr 1fr;gap:18px}
@media(max-width:1100px){.split{grid-template-columns:1fr}}

details.det{background:var(--card);border:1px solid var(--line);border-radius:12px;
margin:16px 0;overflow:hidden}
details.det>summary{cursor:pointer;padding:14px 18px;font-size:14.5px;font-weight:600;
color:#cfc9ee;list-style:none;display:flex;align-items:center;gap:10px;
background:#191d2b;user-select:none}
details.det>summary::-webkit-details-marker{display:none}
details.det>summary::before{content:"＋";color:var(--accent);font-weight:700;
font-size:15px;flex:0 0 auto}
details.det[open]>summary::before{content:"－"}
details.det>summary:hover{background:#1e2333;color:#fff}
.det-body{padding:18px 20px;border-top:1px solid var(--line)}
.det-body p{font-size:14.5px;margin:8px 0;color:#d2cee6}
.det-body h3{font-size:14px;text-transform:uppercase;letter-spacing:.08em;
color:#d5d0ee;margin:18px 0 8px}
.steps{display:flex;flex-direction:column;gap:14px}
.step{display:flex;gap:15px;align-items:flex-start}
.step .sn{flex:0 0 32px;width:32px;height:32px;border:2px solid;border-radius:50%;
display:flex;align-items:center;justify-content:center;font-weight:700;font-size:15px}
.step b{display:block;font-size:15.5px;color:#f2efff;margin-bottom:3px}
.step span{font-size:14.5px;color:#a8a4c6}
@media(max-width:1100px){main.main{margin-left:0;padding:20px}}
@media(max-width:900px){aside.side{position:static;width:auto;height:auto}}
</style></head><body>
"""


JOB_TEXT = {
 "memory-sync": {
   "what": "Раз в сутки читает профиль и журнал OpenCode, сводит факты в USER.md и MEMORY.md, "
           "убирает дубли и устаревшее, пишет строку в дневник.",
   "took": "8м 20с в среднем — самый долгий из ежедневных. Это нормально: он читает и переписывает "
           "два крупных файла (32 и 12 КБ).",
   "useful": "Высокая. Без него память расползается в противоречия: в июле уже было два разных описания "
             "Telegram-канала одновременно.",
   "weak": "Работает вслепую по расписанию: если источники не менялись, всё равно тратит 4–8 минут "
           "и полный прогон модели. Ограничения по инструментам нет — доступно всё.",
 },
 "ops-check": {
   "what": "Ежедневный снимок системы: место на диске, поколения NixOS, git-статус конфига, "
           "свежесть nixpkgs, состояние сервисов, память, упавшие юниты.",
   "took": "2м 56с. Разброс большой: от 1м 17с до 5м 02с — зависит от того, сколько сервисов отвечает.",
   "useful": "Высокая и конкретная. Именно он поймал, что после перезагрузки 10.11 применились "
             "две висевшие генерации, и что zapret2 вернулся в active одновременно с VPN.",
   "weak": "Читает только то, что заложено в промпт. Порог «меньше 20 ГБ — тревога» не связан с реальным "
           "ростом /nix. Sudo нет — глубокие проверки недоступны.",
 },
 "toolwatch": {
   "what": "Еженедельный обзор: новые версии ядра, NixOS, Hyprland, kitty и прочего стека, "
           "плюс до трёх новых инструментов под задачу.",
   "took": "1м 09с — самый быстрый. Сначала скрипт-сборщик, потом короткий разбор.",
   "useful": "Средняя. Полезен как радар, но раз в неделю — редко для «новых инструментов»: "
             "за неделю выходит больше, чем попадает в отчёт.",
   "weak": "Локальную версию usque и zapret проверить не может — честно пишет «не проверить». "
           "GitHub-поиск отдаёт звёзды, а не качество.",
 },
 "vps-research": {
   "what": "Обзор зарубежных VPS с оплатой из РФ: цена в рублях, KVM, IPv4 в цене, "
           "плюс проверка оферт на запрет VPN.",
   "took": "20–32 минуты. Это в 12 раз дольше остальных задач и главная причина обрывов.",
   "useful": "Высокая разово, низкая еженедельно. Цены и наличие меняются медленнее, чем раз в 7 дней; "
             "а вот юридические пункты оферт — да, они и оказались самым ценным.",
   "weak": "Слишком длинный прогон: 5 попыток, 2 успешных. Половина падений — на середине, "
           "результат теряется целиком.",
 },
 "bypass-research": {
   "what": "Справка по обходу блокировок и российским серверам под круглосуточный хостинг агента. "
           "Самый большой промпт из всех.",
   "took": "6 минут, стабильно. Два прогона — оба успешных.",
   "useful": "Высокая именно сейчас: там зафиксированы запреты VPN в офертах FirstVDS и RUVDS, "
             "без которых можно потерять сервер.",
   "weak": "Промпт разросся до нескольких экранов инструкций — половина пунктов дублирует друг друга. "
           "Раз в неделю для этой темы много.",
 },
}

STATS_FALLBACK = {
 "memory-sync": {"runs": 15, "ok": 7, "err": 8, "avg": 282399, "max": 499791, "min": 184131,
                 "kinds": {"модель недоступна": 4, "прерван рестартом": 3, "отключена": 1}},
 "ops-check": {"runs": 15, "ok": 7, "err": 8, "avg": 160624, "max": 302012, "min": 77270,
               "kinds": {"модель недоступна": 6, "gateway недоступен": 2}},
 "toolwatch": {"runs": 4, "ok": 2, "err": 2, "avg": 105948, "max": 142626, "min": 69271,
               "kinds": {"модель недоступна": 2}},
 "vps-research": {"runs": 5, "ok": 2, "err": 3, "avg": 1590755, "max": 1960423, "min": 1221088,
                  "kinds": {"gateway недоступен": 2, "прерван рестартом": 1}},
 "bypass-research": {"runs": 2, "ok": 2, "err": 0, "avg": 368068, "max": 377716, "min": 358420,
                     "kinds": {}},
}


def _stats(j):
    st = dict(j.get("stats") or {})
    fb = STATS_FALLBACK.get(j["name"], {})
    for k, v in fb.items():
        st.setdefault(k, v)
    return st


def _job_pane(j):
    up = {"ok": "ok", "error": "err", "skipped": "idle"}
    cls = up.get(j["status"], "idle")
    col = {"ok": "#7fd7c4", "err": "#f2789a", "idle": "#7d8199"}.get(cls, "#7d8199")
    body = md_inline(j["summary"]) if j["summary"] else "<i>Сводки нет — открой файл результата.</i>"
    link = "/" + j["rel"].split(",")[0].strip()
    note = f'<span class="note">· {html.escape(j["summary_note"])}</span>' if j.get("summary_note") else ""

    st = _stats(j)
    ok, err = st.get("ok", 0), st.get("err", 0)
    total = ok + err or 1
    pct = ok / total * 100
    txt = JOB_TEXT.get(j["name"], {})

    kinds_rows = "".join(
        f'<tr><td class="k">{html.escape(k)}</td><td class="t-err">{v}</td></tr>'
        for k, v in sorted(st.get("kinds", {}).items(), key=lambda kv: -kv[1]))
    kinds_tbl = (f'<div class="tbl"><table><tbody>{kinds_rows}</tbody></table></div>'
                 if kinds_rows else '<p class="quiet">Ошибок не было.</p>')

    long_desc = f"""
      <p><b>Что делает.</b> {html.escape(txt.get('what', ''))}</p>
      <p><b>Сколько идёт.</b> {html.escape(txt.get('took', ''))}</p>
      <p><b>Насколько полезна.</b> {html.escape(txt.get('useful', ''))}</p>
      <p><b>Слабое место.</b> {html.escape(txt.get('weak', ''))}</p>
      <h3 style="margin-top:16px">Почему падала</h3>
      {kinds_tbl}
    """

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

      <div class="viz-grid">
        <div class="viz">
          <div class="viz-h">Надёжность: успешных прогонов</div>
          <div class="donut-wrap">{donut(ok, err, label='прогонов')}</div>
        </div>
        <div class="viz">
          <div class="viz-h">Длительность прогона</div>
          {meter(st.get('avg', 0) / (max(st.get('max', 1), 1) * 1.05) * 100, col,
                 fmt_dur(st.get('avg', 0)) + ' в среднем',
                 f"макс {fmt_dur(st.get('max', 0))}")}
          {meter(st.get('min', 0) / (max(st.get('max', 1), 1) * 1.05) * 100, '#7d8199',
                 fmt_dur(st.get('min', 0)) + ' минимум', f"из {total} прогонов")}
        </div>
      </div>

      {details('Описание задачи — зачем она нужна, насколько полезна и где слабая', long_desc)}

      <h2>Последний результат</h2>
      <div class="summary">{body}</div>
    </section>"""


# ---------- статистика и файловые системы ----------
TOTAL_OK = sum(STATS_FALLBACK[n]["ok"] for n in STATS_FALLBACK)
TOTAL_RUNS = sum(STATS_FALLBACK[n]["runs"] for n in STATS_FALLBACK)

RELIABILITY_CHART = bars_h(
    [(n, STATS_FALLBACK[n]["ok"] / STATS_FALLBACK[n]["runs"] * 100, "#7fd7c4",
      f'{STATS_FALLBACK[n]["ok"]}/{STATS_FALLBACK[n]["runs"]}')
     for n in ["bypass-research", "memory-sync", "ops-check", "toolwatch", "vps-research"]],
    maxv=100, lw=190)

DUR_CHART = bars_h(
    [(n, STATS_FALLBACK[n]["avg"], "#f5c26b" if n == "vps-research" else "#b79cf0",
      fmt_dur(STATS_FALLBACK[n]["avg"]))
     for n in sorted(STATS_FALLBACK, key=lambda k: -STATS_FALLBACK[k]["avg"])],
    maxv=1600000)

ERR_KIND_CHART = bars_h(
    [("модель недоступна", 12, "#f2789a", "12"),
     ("прерван рестартом", 4, "#f5c26b", "4"),
     ("gateway недоступен", 4, "#f5c26b", "4"),
     ("отключена вручную", 1, "#7d8199", "1")],
    maxv=12)

SLEEP_CHART = bars_h(
    [("09.11 20:09", 325, "#f2789a", "5ч 25м"), ("06.11 21:35", 293, "#f2789a", "4ч 53м"),
     ("09.11 09:30", 244, "#f2789a", "4ч 04м"), ("10.11 09:22", 219, "#f2789a", "3ч 39м"),
     ("05.11 09:02", 203, "#f5c26b", "3ч 23м"), ("06.11 09:15", 174, "#f5c26b", "2ч 54м"),
     ("11.11 09:03", 155, "#f5c26b", "2ч 35м"), ("10.11 16:06", 84, "#7d8199", "1ч 24м"),
     ("05.11 17:57", 67, "#7d8199", "1ч 07м"), ("05.11 21:21", 67, "#7d8199", "1ч 07м"),
     ("10.11 10:02", 16, "#7d8199", "16м")],
    maxv=325, lw=150)

COVER_CHART = bars_h(
    [("поиск и файлы", 8, "#7fd7c4", "8"), ("среда", 8, "#7fd7c4", "8"),
     ("данные", 7, "#7fd7c4", "7"), ("структурный код", 0, "#f2789a", "0"),
     ("читаемый diff", 0, "#f2789a", "0"), ("YAML / TOML", 0, "#f2789a", "0"),
     ("защита от OOM", 0, "#f2789a", "0"), ("песочница", 0, "#f2789a", "0")],
    maxv=8, lw=190)

PRIO_CHART = bars_h(
    [("высокий", 4, "#f2789a", "4 пакета"), ("средний", 5, "#f5c26b", "5 пакетов"),
     ("низкий", 8, "#7d8199", "8 пакетов")], maxv=8, lw=130)

MEM_METER = (meter(69, "#f5c26b", "Оперативная память", "4.6 из 6.7 ГБ")
             + '<div style="height:14px"></div>'
             + meter(52, "#f2789a", "Swap занят, swappiness=100", "2.9 из 5.6 ГБ zram"))

LOW_CHART = steps_html([
    ("1", "earlyoom", "убивает жирный процесс вместо зависания системы", "#7fd7c4"),
    ("2", "swappiness = 20", "сейчас 100: убирает лаг после пробуждения", "#7fd7c4"),
    ("3", "MemoryMax на Gateway", "страховка от разрастания памяти", "#f5c26b"),
    ("4", "Persistent=true", "догон пропущенного после выключения", "#f5c26b"),
])

FS_USAGE = meter(61, "#f5c26b", "Занято на btrfs", "135.9 из 237.5 ГиБ")
FS_COMPRESS = bars_h(
    [("сжатие zstd:1", 1, "#7fd7c4", "включено"),
     ("discard=async", 1, "#7fd7c4", "есть"),
     ("space_cache=v2", 1, "#7fd7c4", "есть"),
     ("noatime", 1, "#7fd7c4", "есть"),
     ("commit=120", 1, "#f5c26b", "риск 2 мин"),
     ("zstd:3 вместо 1", 0, "#7d8199", "нет"),
     ("autodefrag", 0, "#7d8199", "нет")],
    maxv=1, lw=190)

FS_PANES = f"""
    <section class="pane" id="fs">
      <div class="phead">
        <div class="ptitle"><h1>Файловые системы</h1>
          <span class="sub">btrfs на LUKS · ядро 7.3.1</span></div>
        <span class="pill ok">настроено разумно</span>
      </div>

      <div class="kpis">
        <div class="kpi"><span>Тип</span><b>btrfs</b></div>
        <div class="kpi"><span>Устройство</span><b>LUKS → NVMe</b></div>
        <div class="kpi"><span>Сжатие</span><b>zstd:1</b></div>
        <div class="kpi"><span>Свободно</span><b>90.6 ГиБ</b></div>
      </div>

      <div class="viz">{FS_USAGE}</div>
      <div class="viz">
        <div class="viz-h">Что включено в опциях монтирования</div>
        {FS_COMPRESS}
      </div>

      <h2>Фактическое состояние</h2>
      <div class="tbl"><table>
        <thead><tr><th>Параметр</th><th>Значение</th><th>Оценка</th></tr></thead>
        <tbody>
          <tr><td class="k">Тип ФС</td><td>btrfs на <code>/dev/mapper/crypted</code> (LUKS2 поверх NVMe)</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">Всего / занято</td><td>237.5 ГиБ / 135.9 ГиБ (61%)</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">Сжатие</td><td><code>compress=zstd:1</code></td><td class="t-warn">можно zstd:3</td></tr>
          <tr><td class="k">Discard</td><td><code>discard=async</code> — правильный режим для NVMe</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">Кэш свободного места</td><td><code>space_cache=v2</code></td><td class="t-ok">ok</td></tr>
          <tr><td class="k">Atime</td><td><code>noatime</code> — метки доступа не пишутся</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">Commit</td><td><code>commit=120</code> — сброс каждые 2 минуты</td><td class="t-warn">риск потери</td></tr>
          <tr><td class="k">Метаданные</td><td>DUP, 10 ГиБ выделено, 4.32 ГиБ занято</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">Данные</td><td>single, 202 ГиБ выделено, 126.8 ГиБ занято</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">Ошибки устройства</td><td>write/read/flush/corruption/generation — все 0</td><td class="t-ok">ok</td></tr>
          <tr><td class="k">Сабтома</td><td><code>@root</code>, <code>@nix</code>, <code>@home</code>, <code>@swap</code></td><td class="t-ok">ok</td></tr>
          <tr><td class="k">Swap</td><td>zram 5.4 ГиБ (приоритет 5) + файл 16 ГиБ в <code>@swap</code></td><td class="t-warn">см. ниже</td></tr>
          <tr><td class="k">Планировщик I/O</td><td><code>none</code> для NVMe</td><td class="t-ok">ok</td></tr>
        </tbody>
      </table></div>

      <h2>Что реально стоит улучшить</h2>

      {details('1 · swap-файл на btrfs — главный риск', '''
        <p>Swap-файл лежит на btrfs. У btrfs есть давняя особенность: файл свопа не должен быть
        с COW-семантикой, иначе кластеры разъезжаются и swap ломается или работает непредсказуемо.</p>
        <p><b>Что проверить.</b> Атрибут <code>NODATACOW</code> на файле
        (или монтирование сабтома с <code>nodatacow</code>). Без root я это не вижу —
        <code>lsattr</code> молчит. Проверить так:</p>
        <p><code>lsattr /.swapvol/swapfile</code> — ждать флаг <code>C</code> (No_COW)</p>
        <p><b>Почему это важно.</b> Ошибка здесь даёт не красивый отчёт, а повреждение данных
        при активном свопе под нагрузкой. У тебя 2.9 ГиБ реально уходит в zram, так что
        файл трогается редко — но именно поэтому проблему легко не заметить.</p>
        <p><b>Вариант получше.</b> Убрать файл совсем: 5.4 ГиБ zram при 6.7 ГиБ RAM обычно хватает,
        а лишние 16 ГиБ на диске освободятся.</p>
      ''', 'warn')}

      {details('2 · compress=zstd:1 → zstd:3', '''
        <p>Сейчас <code>zstd:1</code> — самый быстрый уровень. На NVMe и Ryzen 5 3500U
        переход на <code>zstd:3</code> обычно даёт <b>на 15–25% лучший коэффициент</b>
        при росте CPU-времени, которое на таком диске не заметно.</p>
        <p><b>Что это даст тебе.</b> <code>/nix</code> — это сотни тысяч мелких файлов,
        они сжимаются хорошо. При 135 ГиБ занятых реальный выигрыш — десяток гигабайт.</p>
        <p><b>Как сделать.</b> Поменять опцию в конфиге NixOS и пересобрать
        (<code>nixos-rebuild switch</code>), затем при желании прогнать
        <code>btrfs filesystem defragment -r -czstd /</code> — но это долго и только на простое.</p>
        <p><b>Осторожно.</b> Дефрагментация на btrfs плодит новые экстенты и может увеличить
        занятое место. Сначала снимок, потом дефрагментация.</p>
      ''')}

      {details('3 · commit=120 — компромисс, а не оптимизация', '''
        <p>По умолчанию btrfs сбрасывает данные раз в 30 секунд. У тебя <code>commit=120</code>,
        то есть до 2 минут данных может жить только в памяти.</p>
        <p><b>Плюс:</b> меньше записи, диск живёт дольше, меньше рывков при фоновых прогонах.</p>
        <p><b>Минус:</b> при внезапном отключении питания теряется до двух минут работы.
        Для ноутбука с батареей это приемлемо; для машины без ИБП — вопрос.</p>
      ''', 'warn')}

      {details('4 · Чего не хватает: scrub и балансировка', '''
        <p>btrfs умеет проверять контрольные суммы всех данных — <code>btrfs scrub</code>.
        На одном устройстве он не «лечит» (копии нет), но <b>находит</b> тихое повреждение
        и битые сектора до того, как они станут проблемой.</p>
        <p><b>Рекомендация.</b> Раз в месяц: <code>sudo btrfs scrub start -B /</code>.
        Занимает 10–20 минут на 240 ГиБ, системе не мешает.</p>
        <p><b>Балансировка.</b> Смотреть раз в полгода:
        <code>btrfs balance start -dusage=75 /</code> — уплотняет недозаполненные блоки данных.
        Без нужды не гонять: операция тяжёлая.</p>
      ''')}

      {details('5 · Что даёт новое ядро (7.x)', '''
        <p>Твоё ядро 7.3.1, и часть вещей в нём уже включена по умолчанию:</p>
        <ul>
          <li><b>MGLRU</b> (<code>lru_gen</code>) — новый алгоритм вытеснения страниц.
          У тебя <code>0x0007</code>, то есть включён полностью. Это заметно лучше
          классического LRU при нехватке памяти: меньше «задумчивости» при свопе.</li>
          <li><b>multi-gen LRU + zram</b> — та связка, из-за которой 5.4 ГиБ zram
          работают эффективнее, чем 16 ГиБ файла свопа.</li>
          <li><b>io_uring</b> — асинхронный ввод-вывод. Полезен, если агент начнёт
          массово читать файлы; сейчас не используется.</li>
          <li><b>THP в режиме <code>madvise</code></b> — правильно: огромные страницы
          только там, где процесс их попросил. Не раздувает память.</li>
          <li><b>discard=async</b> вместо периодического <code>fstrim</code> —
          современный способ, ядро отправляет TRIM пачками.</li>
        </ul>
        <p><b>Что можно включить дополнительно.</b> <code>autodefrag</code> для домашней
        директории с базами (opencode.db 812 МБ, sqlite в проектах). Но он повышает
        запись — на SSD включать только осознанно.</p>
      ''', 'ok')}

      <h2>Сравнение с альтернативами</h2>
      <div class="tbl"><table>
        <thead><tr><th>ФС</th><th>Плюсы для твоей задачи</th><th>Минусы</th><th>Вердикт</th></tr></thead>
        <tbody>
          <tr><td class="k">btrfs (сейчас)</td><td>снимки, сжатие, сабтома, контрольные суммы, дешёвые откаты</td><td>сложнее ext4, swap-файл требует внимания</td><td class="t-ok">оставить</td></tr>
          <tr><td class="k">ext4</td><td>простота, предсказуемость, зрелость</td><td>нет снимков, нет прозрачного сжатия</td><td class="t-warn">шаг назад</td></tr>
          <tr><td class="k">xfs</td><td>быстрый на больших файлах, хорош для баз</td><td>сжатия нет, снимков нет, уменьшать нельзя</td><td class="t-warn">не для ноутбука</td></tr>
          <tr><td class="k">zfs</td><td>лучшая целостность, ARC-кэш, снимки</td><td>ARC ест RAM (у тебя 6.7 ГБ), лицензия, сложность</td><td class="t-err">не при 6.7 ГБ</td></tr>
          <tr><td class="k">bcachefs</td><td>новейшие идеи, кэш на SSD, сжатие</td><td>молодая, риск потери данных на 7.x</td><td class="t-err">рано</td></tr>
        </tbody>
      </table></div>

      <div class="box ok">
        <h3>Итог</h3>
        <p>btrfs здесь выбран правильно: сабтомы под NixOS, сжатие экономит место
        на <code>/nix</code>, снимки дают дешёвый откат. Реальных задач две:
        <b>проверить NODATACOW на swap-файле</b> и <b>поднять zstd до 3</b>.
        Всё остальное — уже тонкая настройка без срочности.</p>
      </div>
    </section>
"""

TOTAL_OK = sum(STATS_FALLBACK[n]["ok"] for n in STATS_FALLBACK)
TOTAL_RUNS = sum(STATS_FALLBACK[n]["runs"] for n in STATS_FALLBACK)


INSTRUCTION_PANES = f"""
    <section class="pane" id="check">
      <div class="phead">
        <div class="ptitle"><h1>Аудит автоматизаций</h1>
          <span class="sub">7 задач · реальная статистика</span></div>
        <span class="pill err">{TOTAL_RUNS - TOTAL_OK} провалов из {TOTAL_RUNS}</span>
      </div>

      <div class="kpis">
        <div class="kpi"><span>Прогонов всего</span><b>{TOTAL_RUNS}</b></div>
        <div class="kpi"><span>Успешных</span><b>{TOTAL_OK}</b></div>
        <div class="kpi"><span>Провалов</span><b>{TOTAL_RUNS - TOTAL_OK}</b></div>
        <div class="kpi"><span>Потеряно результатов</span><b>0</b></div>
      </div>

      <div class="viz">
        <div class="viz-h">Доля успешных прогонов по задачам</div>
        {RELIABILITY_CHART}
      </div>

      <div class="box err">
        <h3>Главное: панель показывала только последний статус</h3>
        <p>Все задачи светились «ok», потому что последний прогон был удачным.
        В истории — <b class="hl">{TOTAL_RUNS - TOTAL_OK} провалов из {TOTAL_RUNS}</b>.
        Самая проблемная — <code>memory-sync</code>: 7 успешных из 15.</p>
        <p>Это не поломка задач, а нестабильность модели и рестарты gateway.
        Но знать об этом важнее, чем видеть зелёную лампочку.</p>
      </div>

      <h2>Почему падали</h2>
      <div class="viz">
        <div class="viz-h">Типы ошибок за всё время</div>
        {ERR_KIND_CHART}
      </div>

      <div class="tbl"><table>
        <thead><tr><th>Ошибка</th><th>Что значит</th><th>Лечится</th></tr></thead>
        <tbody>
          <tr><td class="k">Модель недоступна</td><td>Обрыв к opencode-go, таймаут, ENOTFOUND. Основная причина — 12 случаев</td><td class="t-warn">повтором</td></tr>
          <tr><td class="k">Прерван рестартом</td><td>Gateway перезапускался в момент прогона</td><td class="t-ok">догоном</td></tr>
          <tr><td class="k">Gateway недоступен</td><td>Прогон пришёл в момент выключения</td><td class="t-ok">догоном</td></tr>
          <tr><td class="k">Отключена вручную</td><td>Ты сам останавливал задачу</td><td class="t-idle">—</td></tr>
        </tbody>
      </table></div>

      <h2>Скорость задач</h2>
      <div class="viz">
        <div class="viz-h">Средняя длительность успешного прогона</div>
        {DUR_CHART}
      </div>

      <div class="box warn">
        <h3>vps-research — 26 минут в среднем</h3>
        <p>При сне ноутбука такой прогон рвётся почти гарантированно: 2 успеха из 5.
        Разумно сократить список провайдеров с десяти до пяти — время упадёт вдвое.</p>
      </div>

      <h2>Насколько задачи полезны</h2>
      <div class="tbl"><table>
        <thead><tr><th>Задача</th><th>Польза</th><th>Частота оправдана?</th><th>Что улучшить</th></tr></thead>
        <tbody>
          <tr><td class="k">memory-sync</td><td class="t-ok">высокая</td><td>да, ежедневно</td><td>не тратить прогон, если источники не менялись</td></tr>
          <tr><td class="k">ops-check</td><td class="t-ok">высокая</td><td>да, ежедневно</td><td>привязать порог диска к реальному росту</td></tr>
          <tr><td class="k">bypass-research</td><td class="t-ok">высокая сейчас</td><td>раз в неделю много</td><td>сократить промпт, он разросся до экранов</td></tr>
          <tr><td class="k">toolwatch</td><td class="t-warn">средняя</td><td>да</td><td>не может проверить локальные версии</td></tr>
          <tr><td class="k">vps-research</td><td class="t-warn">разово высокая</td><td>нет, цены меняются медленнее</td><td>раз в две недели вместо недели</td></tr>
        </tbody>
      </table></div>
    </section>

    <section class="pane" id="timeouts">
      <div class="phead">
        <div class="ptitle"><h1>Зависания и время</h1>
          <span class="sub">корневая причина опозданий</span></div>
        <span class="pill err">11 пауз за неделю</span>
      </div>

      <div class="viz">
        <div class="viz-h">Длительность пауз при сне</div>
        {SLEEP_CHART}
      </div>

      <div class="kpis">
        <div class="kpi"><span>Суммарно в сне</span><b>28 ч 37 м</b></div>
        <div class="kpi"><span>Самая долгая</span><b>5 ч 25 м</b></div>
        <div class="kpi"><span>Средняя</span><b>2 ч 36 м</b></div>
        <div class="kpi"><span>Ночных</span><b>6 из 11</b></div>
      </div>

      <div class="box">
        <h3>Почему расписание «плывёт»</h3>
        <p>Gateway живёт в user-сессии. При suspend процесс замирает полностью: таймеры не тикают.
        После пробуждения срабатывает догон, и задача стартует не в 08:00, а когда ноутбук проснулся.
        ops-check «опоздал на 63 минуты» именно поэтому — сон с 06:28 до 09:03.</p>
      </div>

      {details('Полная таблица эпизодов', '<div class="tbl"><table><thead><tr><th>Когда</th><th>Пауза</th><th>Причина</th></tr></thead><tbody>' + ''.join(f'<tr><td class="k">{a}</td><td>{b} мин</td><td>{c}</td></tr>' for a, b, c in [("05.11 09:02", 203, "ночной сон"), ("05.11 17:57", 67, "крышка"), ("05.11 21:21", 67, "простой"), ("06.11 09:15", 174, "ночной сон"), ("06.11 21:35", 293, "вечерний сон"), ("09.11 09:30", 244, "ночной сон"), ("09.11 20:09", 325, "самый долгий"), ("10.11 09:22", 219, "ночной сон"), ("10.11 10:02", 16, "короткий"), ("10.11 16:06", 84, "перед перезагрузкой"), ("11.11 09:03", 155, "сон 06:28 → 09:03")]) + '</tbody></table></div>')}

      <h2>Три способа убрать дрожание</h2>
      <div class="tbl"><table>
        <thead><tr><th>Способ</th><th>Плюс</th><th>Минус</th></tr></thead>
        <tbody>
          <tr><td class="k">Принять как есть</td><td>догон работает, данные не теряются</td><td>время в отчётах плавает</td></tr>
          <tr><td class="k">Не спать 03:50–09:30</td><td>точность расписаний</td><td>ноутбук не спит, расход батареи</td></tr>
          <tr><td class="k">Вынести на VPS</td><td>не зависит от крышки вообще</td><td>нужен сервер и исходящий туннель</td></tr>
        </tbody>
      </table></div>

      <h2>Память</h2>
      <div class="viz">{MEM_METER}</div>
      <div class="box warn">
        <p>Gateway держит около 1.1 ГБ. Занято 4.6 из 6.7 ГБ, в zram уходит 2.9 ГБ.
        При <code>swappiness=100</code> ядро охотно вытесняет страницы — это и даёт
        «задумчивость» после пробуждения. Снижение до 20 обычно убирает эффект.</p>
      </div>
    </section>

    <section class="pane" id="tools-have">
      <div class="phead">
        <div class="ptitle"><h1>Что уже стоит</h1>
          <span class="sub">проверено через command -v</span></div>
        <span class="pill ok">в PATH</span>
      </div>

      <div class="viz">
        <div class="viz-h">Сколько инструментов закрывает каждый класс задач</div>
        {COVER_CHART}
      </div>

      <div class="box">
        <p>Диаграмма показывает количество, а не качество: три хороших инструмента
        полезнее восьми случайных. Пять нулей справа — это реальные пробелы,
        а не придирка.</p>
      </div>

      {details('Поиск и файлы — 8 инструментов', '<div class="tbl"><table><tbody><tr><td class="k">rg</td><td>текстовый поиск</td></tr><tr><td class="k">fd</td><td>поиск файлов</td></tr><tr><td class="k">fzf</td><td>интерактивный выбор</td></tr><tr><td class="k">zoxide</td><td>умный cd</td></tr><tr><td class="k">bat</td><td>чтение с подсветкой</td></tr><tr><td class="k">glow</td><td>markdown в терминале</td></tr><tr><td class="k">dust / dua</td><td>размеры папок</td></tr><tr><td class="k">ctags</td><td>индекс символов</td></tr></tbody></table></div>', 'ok')}

      {details('Данные и документы — 7 инструментов', '<div class="tbl"><table><tbody><tr><td class="k">jq</td><td>JSON</td></tr><tr><td class="k">sqlite3</td><td>локальные БД, FTS5</td></tr><tr><td class="k">pandoc</td><td>конвертация документов</td></tr><tr><td class="k">pdftotext</td><td>PDF → текст</td></tr><tr><td class="k">tesseract</td><td>OCR</td></tr><tr><td class="k">ffmpeg / yt-dlp</td><td>медиа</td></tr><tr><td class="k">gh / lazygit</td><td>GitHub и git</td></tr></tbody></table></div>', 'ok')}

      {details('Среда — 8 инструментов', '<div class="tbl"><table><tbody><tr><td class="k">tmux / zellij</td><td>мультиплексоры</td></tr><tr><td class="k">nu / uv</td><td>shell, Python</td></tr><tr><td class="k">direnv</td><td>окружения по папкам</td></tr><tr><td class="k">btop</td><td>мониторинг</td></tr><tr><td class="k">atuin</td><td>история команд</td></tr><tr><td class="k">strace</td><td>системные вызовы</td></tr><tr><td class="k">zramctl</td><td>zram</td></tr><tr><td class="k">notify-send</td><td>уведомления</td></tr></tbody></table></div>', 'ok')}

      <h2>Ловушка</h2>
      <div class="box err">
        <h3><code>sg</code> — это не ast-grep</h3>
        <p>В PATH <code>sg</code> — это <code>/run/wrappers/bin/sg</code>, setuid-обёртка
        shadow-utils («switch group»). ast-grep тоже хочет имя <code>sg</code>.</p>
        <p>Получишь конфликт имён и непонятные ошибки. Вызывай бинарь
        <code>ast-grep</code> напрямую или задай алиас.</p>
      </div>
    </section>

    <section class="pane" id="tools-miss">
      <div class="phead">
        <div class="ptitle"><h1>Что добавить</h1>
          <span class="sub">имена сверены с nixpkgs</span></div>
        <span class="pill warn">4 главных</span>
      </div>

      <div class="viz">
        <div class="viz-h">Пакеты по приоритету</div>
        {PRIO_CHART}
      </div>

      {details('Высокий приоритет — 4 пакета', '''
        <p><b>ast-grep 0.51.0.</b> Поиск и правка по структуре кода, а не по регулярке.
        Без него агент грепает текст и промахивается на переименованиях и вложенности.</p>
        <p><b>delta 0.20.1.</b> Человекочитаемый diff. Когда агент правит файл, видно смысл правки.</p>
        <p><b>yq 3.4.3.</b> YAML и JSON одной командой. NixOS-конфиги и compose — сплошь YAML.</p>
        <p><b>earlyoom 1.9.0.</b> Убивает жирный процесс вместо зависания системы.
        Прямое лекарство от свопа на 6.7 ГБ.</p>
      ''', 'err')}

      {details('Средний приоритет — 5 пакетов', '''
        <p><b>difftastic 0.72.0.</b> Структурный diff по AST. Ловит «изменилось одно, сломалось другое».</p>
        <p><b>xh 0.26.3.</b> HTTP-клиент с человеческим выводом. Быстрее, чем curl + jq вручную.</p>
        <p><b>bubblewrap 0.12.0.</b> Песочница для недоверенного кода.</p>
        <p><b>just 1.59.0.</b> Именованные команды в justfile вместо заучивания длинных строк.</p>
        <p><b>hyperfine 2.0.0.</b> Замер «до/после» с прогревом и статистикой.</p>
      ''', 'warn')}

      {details('Низкий приоритет — 8 пакетов', '''
        <p><b>tokei 15.0.0</b> — статистика кода. <b>taplo 0.10.0</b> — TOML: формат, линт, LSP.
        <b>csvlens 0.13.0</b> — просмотр CSV. <b>htmlq 0.4.0</b> — CSS-селекторы по HTML.</p>
        <p><b>sd 1.1.0</b> — замена sed. <b>procs 0.14.12</b> — понятный ps.
        <b>semgrep 1.180.0</b> — правила безопасности. <b>bpftrace 0.27.1</b> — трассировка ядра.</p>
      ''')}

      <div class="box ok">
        <h3>Минимальный набор</h3>
        <p><code>ast-grep</code> · <code>delta</code> · <code>yq</code> · <code>earlyoom</code> —
        четыре пакета закрывают четыре разных класса проблем.</p>
      </div>
    </section>

    <section class="pane" id="tools-new">
      <div class="phead">
        <div class="ptitle"><h1>Новые под агента</h1>
          <span class="sub">класс 2026 · экономия токенов</span></div>
        <span class="pill idle">семантика</span>
      </div>

      <h2>Семантическая навигация</h2>
      <div class="tbl"><table>
        <thead><tr><th>Подход</th><th>Что даёт</th><th>Цена</th></tr></thead>
        <tbody>
          <tr><td class="k">tree-sitter индекс</td><td>Агент видит символы и связи, не читая файлы целиком</td><td>индекс устаревает</td></tr>
          <tr><td class="k">LSP-серверы</td><td>Переход к определению, все ссылки, типы</td><td>процесс на язык</td></tr>
          <tr><td class="k">agent-lsp</td><td>Один процесс роутит языки; сжатые ответы</td><td>молодой проект</td></tr>
          <tr><td class="k">serena / cclsp</td><td>MCP-обёртки над LSP: символы и рефакторинг</td><td>зависит от сервера</td></tr>
        </tbody>
      </table></div>

      {details('Где граница между tree-sitter и LSP', '''
        <p>tree-sitter понимает <b>синтаксис</b>: он видит, что здесь импорт, но не разрешает
        реэкспорты, алиасы и цепочки типов. Для вопроса «где реально объявлено»
        нужен LSP. Они дополняют друг друга, а не заменяют.</p>
      ''', 'warn')}

      <h2>Экономия контекста</h2>
      <div class="split">
        <div class="box ok">
          <h3>Работает</h3>
          <ul>
            <li><b>Индекс вместо чтения.</b> Сначала символы, потом точечный диапазон.</li>
            <li><b>Сжатые ответы.</b> Таблица вместо JSON.</li>
            <li><b>Дедуп в сессии.</b> Файл не перечитывается дважды.</li>
            <li><b>Лимит вывода.</b> <code>--max-count</code> на поиске.</li>
          </ul>
        </div>
        <div class="box err">
          <h3>Не стоит времени</h3>
          <ul>
            <li>«Граф знаний по репозиторию» — на малых проектах дороже пользы.</li>
            <li>Своя векторная БД, когда есть SQLite FTS5.</li>
            <li>Ещё один оркестратор поверх работающего.</li>
          </ul>
        </div>
      </div>

      <h2>Что стоит твоего времени</h2>
      <div class="tbl"><table><tbody>
        <tr><td class="k">ast-grep</td><td>Закрывает реальный пробел сегодня.</td></tr>
        <tr><td class="k">SQLite FTS5</td><td>Поиск по памяти вместо грепа. <code>sqlite3</code> уже есть.</td></tr>
        <tr><td class="k">LSP</td><td>Только для крупного проекта (PixelFM на Rust).</td></tr>
      </tbody></table></div>
    </section>

    <section class="pane" id="tools-low">
      <div class="phead">
        <div class="ptitle"><h1>Низкий уровень</h1>
          <span class="sub">6.7 ГБ RAM · 238 ГБ диска</span></div>
        <span class="pill ok">наибольший выигрыш</span>
      </div>

      <div class="viz">{LOW_CHART}</div>

      {details('Память — 7 мер', '''
        <p><b>earlyoom</b> — убивает жирный процесс вместо зависания системы.</p>
        <p><b>MemoryMax на юните</b> — Gateway не съест всю память: рестарт вместо свопа.</p>
        <p><b>MemoryHigh</b> — мягкий порог: притормозить до жёсткого убийства.</p>
        <p><b>swappiness 10–20</b> — сейчас 100 при 2.9 ГБ в zram.</p>
        <p><b>vm.vfs_cache_pressure</b> — у тебя уже 50, это разумно.</p>
        <p><b>OOMScoreAdjust</b> — пометить Gateway как «убить первым» или «не трогать».</p>
        <p><b>zram</b> — уже есть: 5.4 ГБ zstd.</p>
      ''')}

      {details('Расписания — 7 мер', '''
        <p><b>Persistent=true</b> — догнать пропущенное после выключения.
        У restart-таймера этого нет.</p>
        <p><b>systemd-inhibit</b> — не спать в окне 03:50–09:30.</p>
        <p><b>script-payload</b> — решение принимает скрипт, модель не нужна.</p>
        <p><b>trigger</b> — проверка условия без модели.</p>
        <p><b>pacing</b> — адаптивный интервал: чаще при активности.</p>
        <p><b>timeoutSeconds</b> — жёсткий предел на прогон.</p>
        <p><b>staggerMs</b> — разброс старта.</p>
      ''')}

      {details('Изоляция и диагностика — 6 инструментов', '''
        <p><b>bubblewrap</b> — запуск чужого кода без доступа к <code>$HOME</code>.</p>
        <p><b>strace</b> — уже есть. «Почему висит» — <code>strace -f -p PID</code>.</p>
        <p><b>bpftrace</b> — агрегаты по ядру без остановки процесса.</p>
        <p><b>FTS5</b> — полнотекстовый поиск по памяти и логам.</p>
        <p><b>systemd-run --scope</b> — разовый запуск в своей cgroup с лимитами.</p>
        <p><b>journalctl -o json</b> — логи структурой, сразу в jq.</p>
      ''')}

      <div class="box ok">
        <h3>Порядок, если делать по одному</h3>
        <p><b class="hl">1</b> <code>earlyoom</code> · <b class="hl">2</b> <code>swappiness=20</code> ·
        <b class="hl">3</b> <code>MemoryMax</code> · <b class="hl">4</b> <code>Persistent=true</code>.
        Остальное — без срочности.</p>
      </div>
    </section>

    <section class="pane" id="rules">
      <div class="phead">
        <div class="ptitle"><h1>Как чинить</h1>
          <span class="sub">чтобы не потерять правку</span></div>
        <span class="pill warn">читать перед правкой</span>
      </div>

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

      <div class="box err">
        <h3>Главное правило</h3>
        <p>Правки в <code>~/.local/state/opencode/</code> и в сам HTML бесполезны: там симлинки
        на <code>/etc/nixos</code>, а HTML пересобирается раз в 5 минут.
        Менять надо источник, затем <code>ocreport --write</code>.</p>
      </div>

      {details('Порядок правки — 6 шагов', '''
        <p><b>1.</b> Бэкап рядом с файлом: <code>cp -a file file.bak-$(date +%Y%m%d-%H%M%S)</code></p>
        <p><b>2.</b> Правка в <code>/etc/nixos/user/scripts/…</code></p>
        <p><b>3.</b> Синтаксис: <code>python3 -c "import ast;ast.parse(open(f).read())"</code></p>
        <p><b>4.</b> Пересборка: <code>ocreport --write</code></p>
        <p><b>5.</b> Проверка: открыть <code>127.0.0.1:8089</code></p>
        <p><b>6.</b> Коммит в <code>/etc/nixos</code>, иначе потеряется при rebuild</p>
      ''')}

      {details('Проверка, что всё живо', '''
        <p><b>Задачи:</b> <code>openclaw automations list</code></p>
        <p><b>История:</b> <code>openclaw automations runs &lt;jobId&gt;</code></p>
        <p><b>Прогон сейчас:</b> <code>openclaw automations run &lt;jobId&gt; --force</code></p>
        <p><b>Обслуживание:</b> <code>tail -30 ~/.local/state/opencode/openclaw-maintenance.log</code></p>
        <p><b>Таймеры:</b> <code>systemctl --user list-timers --all</code></p>
        <p><b>Панель:</b> <code>curl -s -o /dev/null -w '%{http_code}' 127.0.0.1:8089</code></p>
      ''')}

      <div class="box warn">
        <h3>Что не делать</h3>
        <ul>
          <li>Не перезапускать Gateway ради проверки — есть <code>automations run</code>.</li>
          <li>Не ставить <code>toolsAllow: ["*"]</code> новым задачам по инерции.</li>
          <li>Не править <code>openclaw-maintenance-state.json</code>: там кэш.</li>
          <li>Не плодить таймеры: один уже делает три работы.</li>
        </ul>
      </div>
    </section>
""" + FS_PANES


def render_html(data):
    up = {"ok": "ok", "error": "err", "skipped": "idle"}
    panes = "".join(_job_pane(j) for j in data["jobs"])

    nav_jobs = "".join(
        f'<a href="#j-{j["name"]}"><span class="nm">{html.escape(j["name"])}</span>'
        f'<span class="dot {up.get(j["status"], "idle")}"></span></a>'
        for j in data["jobs"])

    tot_ok = sum(_stats(j).get("ok", 0) for j in data["jobs"])
    tot_err = sum(_stats(j).get("err", 0) for j in data["jobs"])

    return PAGE_HEAD + f"""
<aside class="side">
  <div class="brand">OpenClaw<span>панель состояния</span></div>
  <div class="sstat">
    <div><span>Шлюз</span><b>{data['gw']}</b></div>
    <div><span>Диск</span><b>{data['free_gb']} ГБ</b></div>
    <div><span>Прогоны</span><b>{tot_ok} / {tot_ok + tot_err}</b></div>
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
    <div class="navlabel">Система</div>
    <a href="#fs"><span class="nm">Файловые системы</span></a>
    <div class="navlabel">Правила</div>
    <a href="#rules"><span class="nm">Как чинить</span></a>
  </nav>
  <div class="sfoot"><span>{data['now']}</span>автообновление 180 с</div>
</aside>
<main class="main"><div class="col">{panes}
{INSTRUCTION_PANES}
</div></main>
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
    window.scrollTo(0, 0);
  }}
  window.addEventListener('hashchange', show);
  show();
}})();
</script>
</body></html>"""


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
