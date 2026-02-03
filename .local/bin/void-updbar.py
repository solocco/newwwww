#!/usr/bin/python3
import json
from pathlib import Path

UPD_DIR = Path("/tmp/upd")
count_f = UPD_DIR / "count"
lock_f  = UPD_DIR / "refresh.lock"

# Baca count → default "0" sebagai string
text = "0"
if count_f.exists():
    try:
        text = count_f.read_text().strip() or "0"
    except:
        text = "0"

# Jika lock ada → override text jadi "-"
if lock_f.exists():
    text = "-"

# Tooltip opsional (bisa diisi lebih detail kalau `tooltip: true`)
tooltip = ""

# Waybar hanya butuh SATU JSON
print(json.dumps({
    "text": text,
    "tooltip": tooltip
}, ensure_ascii=False))
