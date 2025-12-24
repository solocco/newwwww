#!/usr/bin/python3
# -*- coding: utf-8 -*-

from pathlib import Path
import json

UPD_DIR = Path("/tmp/upd")
count_f = UPD_DIR / "count"
lock_f  = UPD_DIR / "refresh.lock"

count = "0"
if count_f.exists():
    try:
        count = str(int(count_f.read_text().strip()))
    except Exception:
        count = "0"

# ===== COUNT STATE =====
if lock_f.exists():
    text = "-"       # refresh → DASH
else:
    text = count     # 0 atau jumlah update

data = {
    "class": "value",
    "text": text,
    "tooltip": ""
}

print(json.dumps(data, ensure_ascii=False))
