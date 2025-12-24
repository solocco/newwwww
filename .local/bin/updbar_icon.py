#!/usr/bin/python3
# -*- coding: utf-8 -*-

from pathlib import Path
import json

UPD_DIR = Path("/tmp/upd")
count_f = UPD_DIR / "count"

count = 0
if count_f.exists():
    try:
        count = int(count_f.read_text().strip())
    except Exception:
        count = 0

# ===== ICON STATE (NO REFRESH STATE AT ALL) =====
if count > 0:
    data = {
        "class": "updates",
        "percentage": 2,   # icon ada update
        "tooltip": ""
    }
else:
    data = {
        "class": "idle",
        "percentage": 0,   # icon normal
        "tooltip": ""
    }

print(json.dumps(data, ensure_ascii=False))
