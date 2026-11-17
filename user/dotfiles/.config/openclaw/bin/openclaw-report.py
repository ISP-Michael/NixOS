#!/usr/bin/env python3
"""Панель OpenClaw: реестр автоматизаций + свежесть отчётов.

Читает только:
- ~/.openclaw/state/openclaw.sqlite (cron_jobs, cron_run_receipts) в режиме ro;
- automations.json (реестр);
- файлы отчётов в ~/.openclaw/workspace.

Пишет DASHBOARD.md и DASHBOARD.html только при --write.
Ничего не запускает и не меняет в OpenClaw.
"""
import datetime
import html
import json
import os
import pathlib
import re
import sqlite3
import sys

WORK = pathlib.Path.home() / ".openclaw/workspace"
DB = pathlib.Path.home() / ".openclaw/state/openclaw.sqlite"
REG = WORK / "automations.json"
SECTIONS = [
    ("ops", "Система"),
    ("memory", "Память"),
    ("sessions", "Сессии"),
    ("research", "Исследования"),
    ("vps", "VPS"),
    ("directions", "Направления"),
    ("audit", "Аудит"),
    ("internal", "Служебное"),
]
WEEKDAYS = ["вс", "пн", "вт", "ср", "чт", "пт", "сб"]
PREF_HEADINGS = [
    "## Сначала сделать",
    "## Коротко",
    "## TL;DR",
    "## Итог",
    "## Что стоит запомнить",
    "## Оценка",
    "## Что делать",
]


def now_local():
    return datetime.datetime.now().astimezone()


def fmt_ts(ms):
    if not ms:
        return "—"
    try:
        return datetime.datetime.fromtimestamp(ms / 1000).strftime("%d.%m %H:%M")
    except Exception:
        return "—"


def run_label(j):
    return j["last"] if j["last_dt"] else "нет прогона"


def fmt_age(hours):
    if hours is None:
        return "—"
    if hours < 1:
        return f"{int(hours * 60)} мин"
    if hours < 48:
        return f"{int(hours)} ч"
    return f"{int(hours / 24)} дн"


def gb(value, digits=0):
    if value is None:
        return "—"
    return f"{value:.{digits}f} ГБ"


def cron_human(expr):
    if not expr:
        return "—"
    parts = expr.split()
    if len(parts) != 5:
        return expr
    mi, h, dom, mon, dow = parts
    try:
        hh, mm = int(h), int(mi)
    except ValueError:
        return expr
    when = f"{hh:02d}:{mm:02d}"
    if dom == "*" and mon == "*" and dow == "*":
        return f"ежедневно {when}"
    if dom == "*" and mon == "*" and re.fullmatch(r"[0-7]", dow):
        return f"{WEEKDAYS[int(dow) % 7]} {when}"
    if dom != "*" and mon == "*" and dow == "*":
        return f"{dom}-го числа {when}"
    return expr


def load_registry():
    try:
        return json.loads(REG.read_text(encoding="utf-8")).get("jobs", {})
    except Exception:
        return {}


def ro_db():
    uri = f"file:{DB}?mode=ro"
    return sqlite3.connect(uri, uri=True, timeout=5)


def load_jobs():
    conn = ro_db()
    conn.row_factory = sqlite3.Row
    rows = {}
    for r in conn.execute(
        "select job_id, name, enabled, job_json, state_json from cron_jobs order by name"
    ):
        try:
            job = json.loads(r["job_json"] or "{}")
            state = json.loads(r["state_json"] or "{}")
        except Exception:
            continue
        rows[r["name"]] = {
            "id": r["job_id"],
            "name": r["name"],
            "enabled": bool(r["enabled"]),
            "expr": ((job.get("schedule") or {}).get("expr") or ""),
            "kind": ((job.get("payload") or {}).get("kind") or ""),
            "skipped": state.get("consecutiveSkipped") or 0,
            "state": state,
        }
    return rows


def load_receipts(limit_per_job=12):
    conn = ro_db()
    conn.row_factory = sqlite3.Row
    out = {}
    for r in conn.execute(
        "select job_id, status, started_at_ms, finished_at_ms, error_text "
        "from cron_run_receipts order by started_at_ms desc"
    ):
        lst = out.setdefault(r["job_id"], [])
        if len(lst) < limit_per_job:
            lst.append(dict(r))
    return out


def clean_line(line):
    line = line.strip()
    line = re.sub(r"^[-*+]\s+", "", line)
    line = re.sub(r"^\d+\.\s+", "", line)
    line = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", line)
    line = line.replace("**", "").replace("`", "")
    line = re.sub(r"\s+", " ", line)
    return line[:220].strip()


def extract_summary(path, max_lines=5):
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return []
    for heading in PREF_HEADINGS:
        m = re.search(rf"^{re.escape(heading)}.*$", text, re.M)
        if not m:
            continue
        block = text[m.end():]
        block = re.split(r"\n##\s", block)[0]
        lines = [clean_line(x) for x in block.splitlines()]
        lines = [x for x in lines if x and not x.startswith("|")
                 and not x.startswith("#")]
        if lines:
            return lines[:max_lines]
    lines = []
    started = False
    for raw in text.splitlines():
        s = raw.strip()
        if s.startswith("# "):
            started = True
            continue
        if not started or not s or s.startswith("|") or s.startswith("---"):
            continue
        if s.startswith("Обновлено") or s.startswith("Дата проверки"):
            lines.append(clean_line(s))
            continue
        lines.append(clean_line(s))
        if len(lines) >= max_lines:
            break
    return lines[:max_lines]


def section_lines(path, heading, limit=3):
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return []
    m = re.search(rf"^{re.escape(heading)}.*$", text, re.M)
    if not m:
        return []
    block = text[m.end():].split("\n## ", 1)[0]
    out = []
    for line in block.splitlines():
        line = line.strip()
        if line.startswith(("- ", "* ")):
            out.append(clean_line(line[2:]))
        if len(out) >= limit:
            break
    return out


def watch_status():
    try:
        text = (WORK / "research/opencode-watch.md").read_text(encoding="utf-8", errors="replace")
    except Exception:
        return None
    m = re.search(r"Сейчас:\s*\*\*([^*]+)\*\*(.*)", text)
    if not m:
        return None
    return (m.group(1).strip(), m.group(2).strip(" ·\n"))


def health_status(path):
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return None
    m = re.search(r"Статус:\s*\*\*([A-ZА-Я]+)\*\*\s*\(fail:\s*(\d+),\s*warn:\s*(\d+)\)", text)
    if not m:
        return None
    return {"status": m.group(1), "fail": int(m.group(2)), "warn": int(m.group(3))}


def mem_available_gb():
    try:
        for line in pathlib.Path("/proc/meminfo").read_text().splitlines():
            if line.startswith("MemAvailable:"):
                return int(line.split()[1]) / 1024 / 1024
    except Exception:
        pass
    return None


def disk_free_gb():
    try:
        st = os.statvfs("/")
        return st.f_bavail * st.f_frsize / 1024 ** 3
    except Exception:
        return None


def svc_active(name, user=True):
    import subprocess
    cmd = ["systemctl"] + (["--user"] if user else []) + ["is-active", name]
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=5).stdout.strip()
    except Exception:
        return "unknown"


def collect():
    now = now_local()
    reg = load_registry()
    jobs = load_jobs()
    receipts = load_receipts()
    items = []
    for name, job in jobs.items():
        meta = reg.get(name) or {}
        st = job["state"]
        last_ms = st.get("lastRunAtMs") or 0
        last_dt = datetime.datetime.fromtimestamp(last_ms / 1000) if last_ms else None
        status = st.get("lastRunStatus") or st.get("lastStatus") or "—"
        duration = st.get("lastDurationMs") or 0
        rel = meta.get("report")
        report = None
        if rel:
            path = WORK / rel
            if path.exists():
                mtime = path.stat().st_mtime
                age_h = (now.timestamp() - mtime) / 3600
                report = {
                    "rel": rel,
                    "mtime": datetime.datetime.fromtimestamp(mtime),
                    "age_h": age_h,
                    "size": path.stat().st_size,
                    "stale_h": float(meta.get("stale_h") or 26),
                    "stale": age_h > float(meta.get("stale_h") or 26),
                    "summary": ([] if meta.get("summary") is False
                                else extract_summary(path)),
                }
            else:
                report = {"rel": rel, "mtime": None, "age_h": None, "size": 0,
                          "stale_h": float(meta.get("stale_h") or 26),
                          "stale": True, "missing": True, "summary": []}
        hist = receipts.get(job.get("id") or "", [])
        errs = [h for h in hist if h["status"] in ("error", "interrupted")]
        items.append({
            "name": name,
            "title": meta.get("title") or name,
            "section": meta.get("section") or "internal",
            "kind": meta.get("kind") or job["kind"] or "internal",
            "enabled": job["enabled"],
            "expr": job["expr"],
            "when": cron_human(job["expr"]) if job["expr"] else
                    ("каждые 30 мин" if name.startswith("heartbeat") else "—"),
            "status": status,
            "last": fmt_ts(last_ms),
            "last_dt": last_dt,
            "next": fmt_ts(st.get("nextRunAtMs") or 0),
            "duration": duration,
            "consecutive": st.get("consecutiveErrors") or 0,
            "skipped": job.get("skipped") or 0,
            "last_error": (st.get("lastError") or "").strip(),
            "report": report,
            "errors": len(errs),
            "runs": len(hist),
        })
    return {
        "now": now.strftime("%d.%m.%Y %H:%M %Z"),
        "gateway": svc_active("openclaw-gateway"),
        "disk_free": disk_free_gb(),
        "mem_free": mem_available_gb(),
        "jobs": items,
        "memory_health": health_status(WORK / "ops/memory-health.md"),
        "theme_health": health_status(WORK / "ops/theme-health.md"),
        "critic_queue": _queue_count(),
        "watch": watch_status(),
        "vps_issues": section_lines(WORK / "ops/vps-ops.md", "## Сначала посмотреть", 3),
    }


def _queue_count():
    p = WORK / "ops/critic/queue.md"
    if not p.exists():
        return 0
    return sum(1 for line in p.read_text(encoding="utf-8", errors="replace").splitlines()
               if line.strip().startswith(("- ", "* ")))


def unique_reports(data):
    """Один отчёт — одна карточка: выбираем включённую задачу с самым свежим прогоном."""
    best = {}
    for j in data["jobs"]:
        rep = j["report"]
        if not rep or rep.get("missing"):
            continue
        score = (bool(j["enabled"]), j["last_dt"] or datetime.datetime.min)
        if rep["rel"] not in best or score > best[rep["rel"]][0]:
            best[rep["rel"]] = (score, j)
    return {rel: j for rel, (_, j) in best.items()}


def current_issues(data):
    issues = []
    if data["gateway"] != "active":
        issues.append(("fail", f"Шлюз OpenClaw: {data['gateway']}"))
    if data["disk_free"] is not None and data["disk_free"] < 20:
        issues.append(("fail", f"Свободно на /: {data['disk_free']:.0f} ГБ (< 20 ГБ)"))
    if data["mem_free"] is not None and data["mem_free"] < 0.4:
        issues.append(("warn", f"Доступно RAM: {data['mem_free']:.1f} ГБ"))
    now = now_local()
    for j in data["jobs"]:
        if not j["enabled"] or j["section"] == "internal":
            continue
        if j["last_dt"] and (now.timestamp() - j["last_dt"].timestamp()) < 86400:
            if j["status"] in ("error", "interrupted"):
                err = j["last_error"].split("(")[0].strip()[:70]
                lvl = "fail" if j["consecutive"] >= 3 else "warn"
                issues.append((lvl, f"{j['title']}: прогон с ошибкой — {err or j['status']}"))
        rep = j["report"]
        if rep and rep.get("missing") and j["last_dt"]:
            issues.append(("warn", f"{j['title']}: отчёта нет ({rep['rel']})"))
        elif rep and not rep.get("missing") and rep.get("stale"):
            age = rep["age_h"] or 0
            lvl = "fail" if age > 2 * float(rep.get("stale_h") or 26) else "warn"
            issues.append((lvl, f"{j['title']}: отчёт не обновлялся {fmt_age(age)}"))
    for label, h in (("Память", data["memory_health"]), ("Темы", data["theme_health"])):
        if h and h["status"] != "OK":
            lvl = "fail" if h["fail"] else "warn"
            issues.append((lvl, f"{label}: {h['status']} (fail {h['fail']}, warn {h['warn']})"))
    if data["critic_queue"]:
        issues.append(("warn", f"Критик: {data['critic_queue']} утверждений ждут решения"))
    if data.get("watch") and data["watch"][0] not in ("operational", "ok"):
        issues.append(("warn", f"OpenCode Zen/Go: {data['watch'][0]} {data['watch'][1]}"))
    for line in data.get("vps_issues") or []:
        issues.append(("warn", f"VPS: {line}"))
    hb = next((j for j in data["jobs"] if j["name"] == "heartbeat-main"), None)
    if hb and hb.get("skipped", 0) > 20:
        issues.append(("info", f"heartbeat: {hb['skipped']} пропусков подряд — выключить"))
    order = {"fail": 0, "warn": 1, "info": 2}
    issues.sort(key=lambda x: order.get(x[0], 3))
    return issues


def render_md(data):
    out = [f"# OpenClaw — состояние", "", f"Обновлено: **{data['now']}** · шлюз: **{data['gateway']}**",
           f"Диск: {gb(data['disk_free'])} свободно · RAM: {gb(data['mem_free'], 1)} доступно", ""]
    issues = current_issues(data)
    out += ["## Сейчас", ""]
    if not issues:
        out.append("Всё в порядке.")
    for lvl, text in issues[:8]:
        out.append(f"- **{lvl.upper()}** — {text}")
    out += ["", "## Автоматизации", "",
            "| Задача | Расписание | Последний | Статус | Свежесть |",
            "|---|---|---|---|---|"]
    for j in data["jobs"]:
        rep = j["report"]
        fresh = "—" if not rep else ("нет файла" if rep.get("missing")
                                    else fmt_age(rep["age_h"]))
        out.append(f"| {j['title']} (`{j['name']}`) | {j['when']} | {j['last']} | "
                   f"{j['status']} | {fresh} |")
    out += ["", "## Отчёты", ""]
    uniq = unique_reports(data)
    for key, label in SECTIONS:
        group = [j for j in data["jobs"] if j["section"] == key and j["report"]
                 and not j["report"].get("missing")
                 and uniq.get(j["report"]["rel"]) is j]
        if not group:
            continue
        out += [f"### {label}", ""]
        for j in group:
            rep = j["report"]
            out.append(f"**{j['title']}** — {run_label(j)} ({j['status'] if j['enabled'] else 'выкл'}), "
                       f"файл {rep['mtime'].strftime('%d.%m %H:%M') if rep['mtime'] else '—'}")
            for line in rep["summary"]:
                out.append(f"- {line}")
            out.append("")
    return "\n".join(out).rstrip() + "\n"


CSS = """
:root{--bg:#0f1117;--panel:#161a23;--line:#252b38;--text:#e6e6ef;--dim:#9aa0b4;
--ok:#6fcf97;--warn:#f2c94c;--fail:#eb5757;--idle:#5a6072;--link:#8ab4f8}
@media (prefers-color-scheme:light){:root{--bg:#f7f7f9;--panel:#fff;--line:#dcdde3;
--text:#1c1e26;--dim:#5c6070;--ok:#1e7f4f;--warn:#8a6d00;--fail:#b42318;--idle:#8b8f9e;--link:#1a56db}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--text);font:15px/1.55 -apple-system,"Segoe UI",Roboto,"Noto Sans",sans-serif}
.wrap{max-width:1100px;margin:0 auto;padding:28px 20px 60px}
h1{font-size:26px;margin:0 0 4px}
h2{font-size:18px;margin:34px 0 10px;border-bottom:1px solid var(--line);padding-bottom:6px}
h3{font-size:16px;margin:0 0 4px}
.meta{color:var(--dim);font-size:13.5px}
nav{display:flex;gap:14px;flex-wrap:wrap;margin:14px 0 0;font-size:14px}
nav a{color:var(--link);text-decoration:none}
table{width:100%;border-collapse:collapse;font-size:14px;background:var(--panel)}
th,td{text-align:left;padding:7px 9px;border-bottom:1px solid var(--line);vertical-align:top}
th{color:var(--dim);font-weight:600;font-size:12.5px;text-transform:uppercase;letter-spacing:.04em}
tr:last-child td{border-bottom:none}
.badge{display:inline-block;padding:1px 7px;border-radius:10px;font-size:12px;border:1px solid var(--line)}
.ok{color:var(--ok)} .warn{color:var(--warn)} .fail{color:var(--fail)} .idle{color:var(--idle)}
.badge.ok{border-color:var(--ok)} .badge.warn{border-color:var(--warn)}
.badge.fail{border-color:var(--fail)} .badge.idle{border-color:var(--idle)}
ul.issues{list-style:none;padding:0;margin:0}
ul.issues li{padding:7px 10px;border-left:3px solid var(--line);background:var(--panel);margin-bottom:6px}
ul.issues li.fail{border-left-color:var(--fail)}
ul.issues li.warn{border-left-color:var(--warn)}
ul.issues li.info{border-left-color:var(--idle)}
.card{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:14px 16px;margin:10px 0}
.card .sub{color:var(--dim);font-size:13px;margin-bottom:8px}
.card ul{margin:0;padding-left:20px}
.card li{margin:3px 0}
a{color:var(--link);text-decoration:none}
a:hover{text-decoration:underline}
footer{margin-top:40px;color:var(--dim);font-size:12.5px}
.flex{display:flex;gap:10px;flex-wrap:wrap;align-items:baseline}
"""


def badge(status, stale=False, enabled=True):
    if not enabled:
        return '<span class="badge idle">выкл</span>'
    if status == "ok" and not stale:
        return '<span class="badge ok">ok</span>'
    if status in ("error", "interrupted") or (stale and status != "ok"):
        return f'<span class="badge fail">{html.escape(status)}</span>'
    if stale:
        return '<span class="badge warn">stale</span>'
    if status in ("running",):
        return '<span class="badge idle">running</span>'
    return f'<span class="badge idle">{html.escape(status)}</span>'


def render_html(data):
    issues = current_issues(data)
    issue_html = []
    for lvl, text in issues[:8]:
        issue_html.append(f'<li class="{lvl}">{html.escape(text)}</li>')
    if not issue_html:
        issue_html.append('<li class="ok">Всё в порядке.</li>')
    more = ""
    if len(issues) > 8:
        more = f'<p class="meta">+{len(issues) - 8} ещё</p>'

    rows = []
    for j in data["jobs"]:
        rep = j["report"]
        fresh = "—" if not rep else ("нет файла" if rep.get("missing") else fmt_age(rep["age_h"]))
        rows.append(
            "<tr>"
            f"<td>{html.escape(j['title'])}<br><span class=\"meta\">{html.escape(j['name'])}</span></td>"
            f"<td>{html.escape(j['when'])}</td>"
            f"<td>{html.escape(run_label(j))}</td>"
            f"<td>{badge(j['status'], bool(rep and rep.get('stale')), j['enabled'])}</td>"
            f"<td>{fresh}</td>"
            f"<td>{j['duration'] // 1000 if j['duration'] else 0} с</td>"
            "</tr>"
        )

    cards = []
    uniq = unique_reports(data)
    for key, label in SECTIONS:
        group = [j for j in data["jobs"] if j["section"] == key and j["report"]
                 and not j["report"].get("missing")
                 and uniq.get(j["report"]["rel"]) is j]
        if not group:
            continue
        cards.append(f'<h2>{label}</h2>')
        for j in group:
            rep = j["report"]
            items = "".join(f"<li>{html.escape(x)}</li>" for x in rep["summary"])
            age = fmt_age(rep["age_h"])
            cards.append(
                '<article class="card">'
                f'<div class="flex"><h3>{html.escape(j["title"])}</h3>'
                f'{badge(j["status"], bool(rep.get("stale")), j["enabled"])}'
                f'<span class="meta">{html.escape(j["name"])} · {html.escape(j["when"])} · '
                f'прогон {html.escape(run_label(j))} · файл {age}</span></div>'
                f'<ul>{items or "<li>Сводки нет — открой файл.</li>"}</ul>'
                f'<p class="meta"><a href="/{html.escape(rep["rel"])}">открыть {html.escape(rep["rel"])}</a></p>'
                '</article>'
            )

    def health_block(label, h):
        if not h:
            return ""
        cls = {"OK": "ok", "WARN": "warn", "FAIL": "fail"}.get(h["status"], "idle")
        return (f'<div class="card"><h3>{label}</h3>'
                f'<p><span class="badge {cls}">{h["status"]}</span> '
                f'fail {h["fail"]}, warn {h["warn"]}</p></div>')

    return f"""<!doctype html><html lang="ru"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="refresh" content="120">
<title>OpenClaw — состояние</title><style>{CSS}</style></head><body><div class="wrap">
<h1>OpenClaw — состояние</h1>
<div class="meta">обновлено {html.escape(data['now'])} · шлюз <b>{html.escape(data['gateway'])}</b>
· диск {gb(data['disk_free'])} · RAM {gb(data['mem_free'], 1)} доступно</div>
<nav><a href="#now">Сейчас</a><a href="#jobs">Автоматизации</a><a href="#reports">Отчёты</a>
<a href="#checks">Проверки</a><a href="/DASHBOARD.md">DASHBOARD.md</a></nav>
<h2 id="now">Сейчас</h2><ul class="issues">{''.join(issue_html)}</ul>{more}
<h2 id="jobs">Автоматизации ({len(data['jobs'])})</h2>
<table><thead><tr><th>Задача</th><th>Расписание</th><th>Последний</th><th>Статус</th><th>Свежесть</th><th>Время</th></tr></thead>
<tbody>{''.join(rows)}</tbody></table>
<div id="reports">{''.join(cards)}</div>
<h2 id="checks">Проверки</h2>
{health_block("Память", data['memory_health'])}
{health_block("Темы", data['theme_health'])}
<footer>Проверка только читает файлы и базу OpenClaw. Ничего не запускает.
Сырые отчёты — в <code>~/.openclaw/workspace</code>.</footer>
</div></body></html>"""


def main():
    data = collect()
    if "--write" in sys.argv:
        (WORK / "DASHBOARD.md").write_text(render_md(data), encoding="utf-8")
        (WORK / "DASHBOARD.html").write_text(render_html(data), encoding="utf-8")
        print(WORK / "DASHBOARD.md")
        print(WORK / "DASHBOARD.html")
    else:
        print(render_md(data))


if __name__ == "__main__":
    main()
