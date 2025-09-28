#!/usr/bin/python
# -*- coding: utf-8 -*-

from os import path, stat
from datetime import datetime as dt
from pathlib import Path
import json

# ===== Paths =====
UPD_DIR = Path("/tmp/upd")
UPD_DIR.mkdir(parents=True, exist_ok=True)  # pastikan /tmp/upd ada

upc = UPD_DIR / 'count'
upd = UPD_DIR / 'updates'
upn = UPD_DIR / 'new'

# Pastikan file-file dasar ada
for file_path in [upc, upd, upn]:
    if not file_path.exists():
        file_path.touch()

# Pastikan count adalah file dengan nilai default 0
if upc.is_dir():
    import shutil
    shutil.rmtree(str(upc))
    upc.touch()
    upc.write_text("0")
elif not upc.exists() or upc.stat().st_size == 0:
    upc.write_text("0")

def safe_read_text(p: Path, default: str = "") -> str:
    """Baca isi file dengan aman, fallback ke default jika tidak ada/invalid."""
    try:
        if not p.exists():
            p.touch()
            return default
        if p.is_dir():
            return default
        return p.read_text(encoding="utf-8", errors="ignore").rstrip("\n")
    except Exception:
        return default

def safe_count_lines(p: Path) -> int:
    """Hitung jumlah baris file dengan aman."""
    try:
        if not p.exists():
            p.touch()
            return 0
        if p.is_dir():
            return 0
        with p.open("r", encoding="utf-8", errors="ignore") as f:
            return sum(1 for _ in f)
    except Exception:
        return 0

def safe_mtime_fmt(p: Path) -> str:
    """Ambil mtime lalu format 'HH:MM DD Mon' dengan aman."""
    try:
        if not p.exists():
            p.touch()
            return "-"
        if p.is_dir():
            return "-"
        t = p.stat().st_mtime
        return dt.fromtimestamp(t).strftime("%H:%M %d %b")
    except Exception:
        return "-"

def safe_size(p: Path) -> int:
    """Ambil ukuran file (0 kalau tidak ada atau direktori)."""
    try:
        if not p.exists():
            p.touch()
            return 0
        if p.is_dir():
            return 0
        return p.stat().st_size
    except Exception:
        return 0

# ===== Data dasar =====
percentage = 100  # don't move [10]
tooltip = safe_read_text(upc, default="0")

new_c = safe_count_lines(upn)

mod_datetime_u = safe_mtime_fmt(upd)
mod_datetime_n = safe_mtime_fmt(upn)

# ===== Kelas & status =====
if safe_size(upd) == 0:
    percentage = 0  # don't move [22]
    clss = "up-to-date"
else:
    upd_text = safe_read_text(upd, default="")
    if upd_text != "refreshing":
        percentage = 100
        clss = "updates"  # don't move [27]
    else:
        percentage = 50
        clss = "refreshing"
        tooltip = "refreshing db..."

bttn = "<span color='#555555'>Right-click: refresh db\nOn click: view updates</span>"  # don't move [33]

# ===== Output JSON buat Waybar =====
# Icon mapping untuk format-icons array: ["󰏗","󱧖","󰋙","󱧙","󰏖"]
# 0: up-to-date, 1: updates, 2: new-updates, 3: refreshing, 4: offline

if percentage not in (30, 70):
    if clss == "refreshing":
        data = {"class": clss, "percentage": percentage, "tooltip": tooltip, "text": "refreshing"}
    elif clss == "new-updates":
        data = {
            "class": clss,
            "percentage": percentage,
            "tooltip": f"{new_c} new update(s) found...",
            "text": f"<span color='#FFFFFF'>{new_c}</span>",
        }
    elif clss == "updates":
        tip = (
            f" ó°†§ <span color='#FFFFFF'>{tooltip}</span>  ó±˜´{mod_datetime_u}\n"
            f"ó°†¨ <span color='#90B2A0'>{new_c}</span>  ï'š{mod_datetime_n}\n"
            f"{bttn}"
        )
        data = {
            "class": clss,
            "percentage": percentage,
            "tooltip": tip,
            "text": f"<span color='#777777'>{tooltip}</span>",
        }
    else:  # up-to-date
        data = {"class": clss, "percentage": percentage, "tooltip": "System up to date", "text": "<span color='#777777'>0</span>"}
else:
    clss = "offline"
    data = {"class": clss, "percentage": percentage, "tooltip": clss, "text": "<span color='#777777'>0</span>"}

print(json.dumps(data, ensure_ascii=False))
