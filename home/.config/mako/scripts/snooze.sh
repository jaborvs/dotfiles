#!/usr/bin/env python3
"""Right-click handler for mako: snooze the clicked notification.

    snooze.sh <notification-id>        (SNOOZE_SECS, default 300)

- calendar-reminder (live counter from reminder.sh): flag it; the tracker
  re-sends it critical after the snooze and keeps counting.
- anything else: dismiss now, re-send after the delay with urgency critical
  ([urgency=high] style: red border, no timeout) and the same summary/body.
  App-name becomes "snoozed" so the global on-notify sound plays.
"""
import json, os, subprocess, sys, time

nid = int(sys.argv[1])
snooze = int(os.environ.get("SNOOZE_SECS", "300"))
state = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "mako-reminder")
os.makedirs(state, exist_ok=True)

out = subprocess.run(
    ["busctl", "--user", "--json=short", "call", "org.freedesktop.Notifications",
     "/fr/emersion/Mako", "fr.emersion.Mako", "ListNotifications"],
    capture_output=True, text=True, check=True).stdout
notes = [{k: v["data"] for k, v in n.items()} for n in json.loads(out)["data"][0]]
n = next((x for x in notes if x["id"] == nid), None)
if n is None:
    sys.exit(0)

if n["app-name"] == "calendar-reminder":
    with open(os.path.join(state, f"snooze-{nid}"), "w") as f:
        f.write(str(snooze))
    subprocess.run(["makoctl", "dismiss", "-n", str(nid)])
    sys.exit(0)

subprocess.run(["makoctl", "dismiss", "-n", str(nid)])
if os.fork():           # parent returns immediately; child waits and re-sends
    sys.exit(0)
os.setsid()
time.sleep(snooze)
cmd = ["notify-send", "-a", "snoozed", "-u", "critical"]
if n.get("app-icon"):
    cmd += ["-i", n["app-icon"]]
subprocess.run(cmd + [n["summary"], n["body"]])
