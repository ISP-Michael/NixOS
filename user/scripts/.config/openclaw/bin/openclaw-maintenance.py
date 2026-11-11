#!/usr/bin/env python3
"""Один обслуживающий проход OpenClaw: catch-up + уведомления + дашборд.

Раз в 2 минуты:
- один раз читает `openclaw automations list` (вместо трёх таймеров);
- догоняет пропущенные/упавшие задачи (с учётом schedule.expr из JSON);
- шлёт desktop/Telegram по новым запускам (Telegram — нативный delivery-recovery);
- раз в 5 минут пересобирает DASHBOARD.md/HTML из кэша, без лишних `runs`.

Никакого Nix: только Python + systemd user units.
"""
import datetime
import fcntl
import importlib.util
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import time

OPENCLAW = os.environ.get("OPENCLAW_BIN") or shutil.which("openclaw") or str(pathlib.Path.home() / ".local/bin/openclaw")
BASE = pathlib.Path.home() / ".local/state/opencode"
WORK = pathlib.Path.home() / ".openclaw/workspace"
CACHE = BASE / "openclaw-maintenance-state.json"
LOCK = BASE / "openclaw-maintenance.lock"
LOG = BASE / "openclaw-maintenance.log"
TELEGRAM_ID = "1531083606"

GRACE = 10 * 60
BACKOFF = 15 * 60
STUCK = 10 * 60
DASHBOARD_EVERY = 5 * 60
MAX_TRIGGERS = 2

JOBS = {
    "memory-sync": {"rel": "USER.md, MEMORY.md", "default": (None, 4, 30)},
    "ops-check": {"rel": "ops/status.md", "default": (None, 8, 0)},
    "toolwatch": {"rel": "research/toolwatch.md", "default": (4, 9, 0)},
    "vps-research": {"rel": "research/vps-foreign.md", "default": (0, 9, 0)},
    "bypass-research": {"rel": "research/bypass-2026.md", "default": (2, 9, 0)},
}
WEEKDAYS = ["пн", "вт", "ср", "чт", "пт", "сб", "вс"]


def log(msg):
    try:
        with LOG.open("a") as f:
            f.write(f"[{time.strftime('%F %T')}] {msg}\n")
    except Exception:
        pass


def oc(args, timeout=30):
    try:
        r = subprocess.run([OPENCLAW] + args, capture_output=True, text=True,
                           timeout=timeout)
        return r.stdout
    except Exception as e:
        log(f"openclaw {args[:2]}: {e}")
        return ""


def load_json(path, default):
    try:
        return json.loads(path.read_text())
    except Exception:
        return default


def save_json(path, data):
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, ensure_ascii=False, indent=1))
    tmp.replace(path)


def ts_fmt(ms):
    if not ms:
        return "—"
    try:
        return datetime.datetime.fromtimestamp(ms / 1000).strftime("%d.%m %H:%M")
    except Exception:
        return "—"


def svc_state(name, user=True):
    cmd = ["systemctl"] + (["--user"] if user else []) + ["is-active", name]
    try:
        return subprocess.run(cmd, capture_output=True, text=True,
                              timeout=10).stdout.strip() or "unknown"
    except Exception:
        return "unknown"


def notify_desktop(title, body, urgency="normal"):
    try:
        r = subprocess.run(["notify-send", "-a", "OpenClaw", "-u", urgency,
                            title, body[:1200]],
                           capture_output=True, text=True, timeout=10)
        if r.returncode != 0:
            log(f"notify-send rc={r.returncode}: {r.stderr.strip()[:200]}")
        return r.returncode == 0
    except Exception as e:
        log(f"notify-send error: {e}")
        return False


def send_telegram(text):
    """sent | submitted | gateway_down | error."""
    try:
        r = subprocess.run(
            [OPENCLAW, "message", "send", "--channel", "telegram",
             "-t", TELEGRAM_ID, "-m", text[:3800], "--json"],
            capture_output=True, text=True, timeout=20)
        out = (r.stdout or "").strip()
        try:
            if json.loads(out).get("ok"):
                return "sent"
        except Exception:
            pass
        low = out.lower()
        if "econnrefused" in low or "not reachable" in low or "gateway not" in low:
            return "gateway_down"
        return "submitted"
    except subprocess.TimeoutExpired:
        return "submitted"
    except Exception as e:
        log(f"telegram error: {e}")
        return "error"


def parse_schedule(name, job):
    expr = ((job or {}).get("schedule") or {}).get("expr") or ""
    parts = expr.split()
    if len(parts) == 5:
        mi, h, dom, mon, dow = parts
        try:
            if dom == "*" and mon == "*" and dow == "*":
                return (None, int(h), int(mi))
            if dom == "*" and mon == "*" and re.fullmatch(r"[0-7]", dow):
                d = int(dow)
                return ((d - 1) % 7, int(h), int(mi))
        except ValueError:
            pass
    return JOBS[name]["default"]


def describe_schedule(sched):
    weekday, hh, mm = sched
    if weekday is None:
        return f"ежедневно {hh:02d}:{mm:02d}"
    return f"{WEEKDAYS[weekday]} {hh:02d}:{mm:02d}"


def expected_last(now, weekday, hh, mm):
    if weekday is None:
        cand = now.replace(hour=hh, minute=mm, second=0, microsecond=0)
        if cand > now:
            cand -= datetime.timedelta(days=1)
        return cand
    days_back = (now.weekday() - weekday) % 7
    cand = (now - datetime.timedelta(days=days_back)).replace(
        hour=hh, minute=mm, second=0, microsecond=0)
    if cand > now:
        cand -= datetime.timedelta(days=7)
    return cand


def network_ok():
    try:
        import socket
        socket.create_connection(("opencode.ai", 443), timeout=5).close()
        return True
    except Exception:
        return False


def provider_status():
    """operational | degraded | outage | unknown — статус Go-инференса."""
    try:
        r = subprocess.run(
            ["curl", "-sS", "-m", "6", "https://opencode.ai/status/api/status"],
            capture_output=True, text=True, timeout=10)
        d = json.loads(r.stdout)
        for c in d.get("components", []):
            if c.get("service") == "go":
                return c.get("status") or "unknown"
    except Exception:
        pass
    return "unknown"


def gateway_ok():
    if svc_state("openclaw-gateway") == "active":
        return True
    log("gateway not active; starting")
    try:
        subprocess.run(["systemctl", "--user", "start", "openclaw-gateway"],
                       capture_output=True, text=True, timeout=45)
    except Exception as e:
        log(f"gateway start error: {e}")
    time.sleep(9)
    return svc_state("openclaw-gateway") == "active"


def health_ok():
    try:
        r = subprocess.run(
            ["curl", "-sS", "-m", "5", "-o", "/dev/null", "-w", "%{http_code}",
             "http://127.0.0.1:18789/health"],
            capture_output=True, text=True, timeout=10)
        return r.stdout.strip() == "200"
    except Exception:
        return False


def restart_gateway():
    log("restarting gateway")
    try:
        subprocess.run(["systemctl", "--user", "restart", "openclaw-gateway"],
                       capture_output=True, text=True, timeout=50)
    except Exception as e:
        log(f"restart error: {e}")
    for _ in range(15):
        time.sleep(2)
        if health_ok():
            log("gateway restarted, health 200")
            return True
    log("graceful restart failed; fallback kill -9")
    try:
        subprocess.run(["systemctl", "--user", "kill", "-s", "KILL",
                        "openclaw-gateway"], capture_output=True, text=True,
                       timeout=20)
        time.sleep(2)
        subprocess.run(["systemctl", "--user", "start", "openclaw-gateway"],
                       capture_output=True, text=True, timeout=45)
    except Exception as e:
        log(f"kill/start error: {e}")
    for _ in range(15):
        time.sleep(2)
        if health_ok():
            log("gateway restarted via kill -9")
            return True
    log("gateway restart failed")
    return False


def mtime_fmt(rel):
    p = WORK / rel.split(",")[0].strip()
    if not p.exists():
        return "—"
    return datetime.datetime.fromtimestamp(p.stat().st_mtime).strftime("%d.%m %H:%M")


def load_report_module():
    path = BASE / "openclaw-report.py"
    spec = importlib.util.spec_from_file_location("ocreport", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def runs_stats(entries):
    """Сводка по истории прогонов: успех/провал, длительности, типы ошибок."""
    ok = [e for e in entries if e.get("status") == "ok"]
    bad = [e for e in entries if e.get("status") != "ok"]
    durs = [int(e.get("durationMs") or 0) for e in ok if e.get("durationMs")]
    kinds = {}
    for e in bad:
        msg = e.get("error") or ""
        if "interrupted by gateway restart" in msg:
            k = "прерван рестартом"
        elif "shutting down" in msg or "receipt authority" in msg:
            k = "gateway недоступен"
        elif "All models failed" in msg:
            k = "модель недоступна"
        elif "disabled by operator" in msg:
            k = "отключена"
        else:
            k = "другое"
        kinds[k] = kinds.get(k, 0) + 1
    recent = [{"s": "ok" if e.get("status") == "ok" else "err",
               "d": int(e.get("durationMs") or 0)} for e in entries[:14]]
    return {
        "runs": len(entries),
        "ok": len(ok),
        "err": len(bad),
        "avg": int(sum(durs) / len(durs)) if durs else 0,
        "max": max(durs) if durs else 0,
        "min": min(durs) if durs else 0,
        "kinds": kinds,
        "recent": recent,
    }


def build_dashboard_data(cache, jobs):
    data = {
        "now": datetime.datetime.now().astimezone().strftime("%d.%m.%Y %H:%M %Z"),
        "gw": svc_state("openclaw-gateway"),
        "svc": {
            "zapret2": svc_state("zapret2", user=False),
            "usque": svc_state("usque"),
            "usque-http": svc_state("usque-http"),
        },
        "free_gb": shutil.disk_usage("/").free // (1024 ** 3),
        "jobs": [],
    }
    for name, meta in JOBS.items():
        j = jobs.get(name) or {}
        cj = cache["jobs"].get(name) or {}
        sched = parse_schedule(name, j)
        data["jobs"].append({
            "name": name,
            "when": describe_schedule(sched),
            "rel": meta["rel"],
            "last": ts_fmt((j.get("state") or {}).get("lastRunAtMs")),
            "next": ts_fmt((j.get("state") or {}).get("nextRunAtMs")
                           or j.get("nextRunAtMs")),
            "status": (j.get("state") or {}).get("lastRunStatus")
                      or (j.get("state") or {}).get("lastStatus") or "—",
            "summary": cj.get("summary") or "",
            "summary_time": ts_fmt(cj.get("summary_ts")),
            "summary_note": cj.get("summary_note") or "",
            "file_time": mtime_fmt(meta["rel"]),
            "stats": cj.get("stats") or {},
        })
    return data


def main():
    lock = LOCK.open("w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        log("already running; skip")
        return

    now = datetime.datetime.now()
    now_ts = time.time()
    cache = load_json(CACHE, {"initialized": False, "jobs": {}, "attempts": {},
                              "last_dashboard": 0})
    cache.setdefault("jobs", {})
    cache.setdefault("attempts", {})

    if not gateway_ok():
        log("skip: gateway failed to start")
        return

    raw = oc(["automations", "list", "--json"])
    try:
        jobs = {j.get("name"): j for j in json.loads(raw).get("jobs", [])}
    except Exception:
        log("skip: cannot parse automations list")
        return

    # застрявший run: runningAtMs старше 10 минут
    for name in JOBS:
        j = jobs.get(name) or {}
        js = j.get("state") or {}
        started = js.get("runningAtMs") or 0
        if started and now_ts - started / 1000 > STUCK:
            a = cache["attempts"].get("__restart") or {}
            if now_ts - a.get("last", 0) > 1800:
                cache["attempts"]["__restart"] = {"last": now_ts}
                if restart_gateway():
                    cache["attempts"].pop(name, None)
                    raw = oc(["automations", "list", "--json"])
                    try:
                        jobs = {x.get("name"): x for x in
                                json.loads(raw).get("jobs", [])}
                    except Exception:
                        pass
                break

    initialized = bool(cache.get("initialized"))
    triggers = 0
    notified = 0
    net = network_ok()
    pstatus = None

    for name, meta in JOBS.items():
        j = jobs.get(name) or {}
        if not j.get("id"):
            continue
        js = j.get("state") or {}
        last = js.get("lastRunAtMs") or 0
        status = js.get("lastRunStatus") or js.get("lastStatus") or "?"
        run_started = js.get("runningAtMs") or 0
        cj = dict(cache["jobs"].get(name) or {})
        new_run = bool(last and last > (cj.get("last") or 0))

        if last and (new_run or not cj.get("summary")):
            entries = []
            try:
                entries = json.loads(oc(["automations", "runs", j["id"],
                                         "--json"])).get("entries") or []
            except Exception:
                pass
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
            prev_error = cj.get("last_error_notify") or 0
            suppress = False
            if status == "error":
                if not initialized:
                    # первый проход: старьё не уведомляем и не блокируем
                    # будущие ошибки часовым cooldown'ом
                    cj["last_error_notify"] = 0
                elif prev_error and now_ts - prev_error < 3600:
                    cj["last_error_notify"] = prev_error
                    suppress = True
                    log(f"suppressed error notify {name}")
                else:
                    cj["last_error_notify"] = now_ts
            else:
                cj["last_error_notify"] = 0
            if entries:
                cj["stats"] = runs_stats(entries)
            cj.update({"last": last, "status": status, "summary": summary,
                       "summary_ts": summary_ts, "summary_note": note})
            cache["jobs"][name] = cj

            if new_run and initialized and not suppress:
                title = f"OpenClaw: {name} — {status}"
                if status == "error":
                    body = entry.get("error") or js.get("lastError") or "Ошибка; смотри лог"
                else:
                    body = summary or "Готово; смотри DASHBOARD.md"
                notify_desktop(title, body,
                               "critical" if status == "error" else "normal")
                res = send_telegram(f"{title}\n\n{body}")
                notified += 1
                log(f"notified {name} status={status} telegram={res}")

        # catch-up
        sched = parse_schedule(name, j)
        exp = expected_last(now, *sched)
        exp_ms = int(exp.timestamp() * 1000)
        age_slot = (now - exp).total_seconds()
        if run_started and now_ts - run_started / 1000 < STUCK:
            continue
        if age_slot < GRACE:
            continue
        if last >= exp_ms and status == "ok":
            cache["attempts"].pop(name, None)
            continue
        if last and now_ts - last / 1000 < 10 * 60:
            continue
        a = cache["attempts"].get(name) or {}
        if a.get("last") and now_ts - a["last"] < BACKOFF:
            continue
        if triggers >= MAX_TRIGGERS:
            continue
        if not net:
            continue
        if pstatus is None:
            pstatus = provider_status()
        if pstatus == "outage":
            log(f"skip {name}: provider outage")
            continue
        log(f"trigger {name}: last={ts_fmt(last)} status={status} "
            f"expected={exp:%F %H:%M} provider={pstatus}")
        oc(["automations", "run", j["id"], "--json"], timeout=40)
        cache["attempts"][name] = {"last": now_ts,
                                   "count": int(a.get("count", 0)) + 1}
        triggers += 1

    cache["initialized"] = True

    if not cache.get("last_dashboard") or now_ts - cache["last_dashboard"] >= DASHBOARD_EVERY:
        try:
            mod = load_report_module()
            data = build_dashboard_data(cache, jobs)
            (WORK / "DASHBOARD.md").write_text(mod.render_md(data), encoding="utf-8")
            (WORK / "DASHBOARD.html").write_text(mod.render_html(data), encoding="utf-8")
            cache["last_dashboard"] = now_ts
            log("dashboard updated")
        except Exception as e:
            log(f"dashboard error: {e}")

    today = now.strftime("%Y-%m-%d")
    if now.hour >= 9 and cache.get("last_digest") != today:
        lines = [f"OpenClaw: daily {now:%d.%m}", ""]
        for name in JOBS:
            cj = cache["jobs"].get(name) or {}
            j = jobs.get(name) or {}
            last = ts_fmt((j.get("state") or {}).get("lastRunAtMs"))
            status = cj.get("status") or "—"
            lines.append(f"• {name} — {status} ({last})")
        text = "\n".join(lines)
        notify_desktop("OpenClaw: daily", text)
        res = send_telegram(text)
        if res != "gateway_down":
            cache["last_digest"] = today
        log(f"daily digest telegram={res}")

    save_json(CACHE, cache)
    log(f"run: triggers={triggers} notified={notified} net={net} provider={pstatus}")


if __name__ == "__main__":
    main()
