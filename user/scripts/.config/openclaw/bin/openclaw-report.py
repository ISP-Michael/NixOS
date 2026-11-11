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
    cards = []
    for j in data["jobs"]:
        cls = {"ok": "ok", "error": "error"}.get(j["status"], "idle")
        body = md_inline(j["summary"]) if j["summary"] else "<i>Сводки нет, смотри файл.</i>"
        link = "/" + j["rel"].split(",")[0].strip()
        cards.append(f"""
        <article class="card">
          <div class="card-head">
            <h2>{html.escape(j['name'])}</h2>
            <span class="badge {cls}">{html.escape(j['status'])}</span>
          </div>
          <div class="meta">{html.escape(j['when'])} · последний запуск {j['last']}
            · <a href="{link}">{html.escape(j['rel'])}</a></div>
          <div class="summary">{body}</div>
          <div class="foot">сводка: {j['summary_time']}{(' · ' + j['summary_note']) if j.get('summary_note') else ''} · файл: {j['file_time']}</div>
        </article>""")
    return f"""<!doctype html>
<html lang="ru"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="refresh" content="60">
<title>OpenClaw — панель</title>
<style>
:root {{ --bg:#10111a; --card:#1b1d2a; --line:#2a2c3d; --text:#e0def4;
         --muted:#908caa; --accent:#c4a7e7; --ok:#9ccfd8; --err:#eb6f92; --warn:#f6c177; }}
* {{ box-sizing:border-box; }}
body {{ margin:0; background:var(--bg); color:var(--text);
        font-family:-apple-system,"Segoe UI",Roboto,"Noto Sans",sans-serif; }}
.wrap {{ max-width:1280px; margin:0 auto; padding:28px 22px 48px; }}
header {{ display:flex; flex-wrap:wrap; align-items:baseline; gap:14px;
          border-bottom:1px solid var(--line); padding-bottom:18px; margin-bottom:22px; }}
h1 {{ font-size:28px; margin:0; letter-spacing:-.02em; }}
.sub {{ color:var(--muted); font-size:14px; }}
.statusline {{ margin:10px 0 22px; color:var(--muted); font-size:14px; line-height:1.7; }}
.statusline b {{ color:var(--text); }}
.grid {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(380px,1fr)); gap:16px; }}
.card {{ background:var(--card); border:1px solid var(--line); border-radius:14px;
         padding:16px 16px 12px; display:flex; flex-direction:column; min-height:220px; }}
.card-head {{ display:flex; justify-content:space-between; align-items:center; gap:10px; }}
.card h2 {{ font-size:17px; margin:0; }}
.badge {{ font-size:12px; padding:3px 9px; border-radius:999px; font-weight:600; }}
.badge.ok {{ background:#1d3a35; color:var(--ok); }}
.badge.error {{ background:#3a1d28; color:var(--err); }}
.badge.idle {{ background:#2a2c3d; color:var(--muted); }}
.meta {{ color:var(--muted); font-size:12.5px; margin:6px 0 10px; }}
.meta a {{ color:var(--accent); text-decoration:none; }}
.summary {{ white-space:pre-wrap; font-size:13.5px; line-height:1.55;
            overflow:auto; max-height:430px; flex:1; }}
.summary a {{ color:var(--accent); }}
.summary code {{ background:#10111a; padding:1px 4px; border-radius:4px; font-size:12.5px; }}
.foot {{ color:var(--muted); font-size:11.5px; margin-top:10px; border-top:1px solid var(--line);
         padding-top:8px; }}
footer {{ margin-top:26px; color:var(--muted); font-size:12.5px; line-height:1.7; }}
footer code {{ color:var(--text); }}
</style></head><body><div class="wrap">
<header><h1>OpenClaw</h1><span class="sub">панель результатов · обновлено {data['now']}</span></header>
<div class="statusline"><b>Шлюз:</b> {data['gw']} · <b>zapret2:</b> {data['svc']['zapret2']}
 · <b>usque:</b> {data['svc']['usque']} · <b>usque-http:</b> {data['svc']['usque-http']}
 · <b>свободно на /:</b> {data['free_gb']} ГБ</div>
<div class="grid">{''.join(cards)}</div>
<footer>Автообновление страницы: 60 с. Полные отчёты — ссылки в карточках.
В терминале: <code>ocreport</code>. Markdown: <code>~/.openclaw/workspace/DASHBOARD.md</code>.</footer>
</div></body></html>"""


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
