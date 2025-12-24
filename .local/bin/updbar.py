#!/usr/bin/python3
# -*- coding: utf-8 -*-

from pathlib import Path
import json
import shutil

UPD_DIR = Path("/tmp/upd")
UPD_DIR.mkdir(parents=True, exist_ok=True)

upc   = UPD_DIR / "count"
upd   = UPD_DIR / "updates"
upn   = UPD_DIR / "new"
lock  = UPD_DIR / "refresh.lock"
state = UPD_DIR / "state"   # ⬅ cache state

for p in [upc, upd, upn, state]:
    if p.exists() and p.is_dir():
        shutil.rmtree(p)
    if not p.exists():
        p.touch()

if upc.stat().st_size == 0:
    upc.write_text("0")

def safe_read(p, default=""):
    try:
        return p.read_text().strip()
    except Exception:
        return default

count = safe_read(upc, "0")
try:
    count_int = int(count)
except ValueError:
    count_int = 0

# =========================
# STATE RESOLUTION (ANTI RACE)
# =========================

if lock.exists():
    cur_state = "refreshing"
elif count_int > 0:
    cur_state = "updates"
else:
    cur_state = "idle"

# simpan state terakhir
state.write_text(cur_state)

# =========================
# RENDER
# =========================

if cur_state == "refreshing":
    data = {
        "class": "refreshing",
        "percentage": 1,
        "tooltip": "",
        "text": "-",          # ⬅ TIDAK BISA DIGANTI 0 LAGI
    }
elif cur_state == "updates":
    data = {
        "class": "updates",
        "percentage": 2,
        "tooltip": "",
        "text": str(count_int),
    }
else:
    data = {
        "class": "idle",
        "percentage": 0,
        "tooltip": "",
        "text": "0",
    }

print(json.dumps(data, ensure_ascii=False))
