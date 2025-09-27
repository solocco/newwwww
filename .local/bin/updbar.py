#!/usr/bin/python
# -*- coding: utf-8 -*-

from os import path, stat
from datetime import datetime as dt
from pathlib import Path
import json

# ===== Paths =====
UPD_DIR = Path("/tmp/upd")
UPD_DIR.mkdir(parents=True, exist_ok=True)  # pastikan /tmp/upd ada

upc = '/tmp/upd/count'
upd = '/tmp/upd/updates'
upn = '/tmp/upd/new'

P_UPC = Path(upc)
P_UPD = Path(upd)
P_UPN = Path(upn)

def safe_read_text(p: Path, default: str = "") -> str:
    """Baca isi file dengan aman, fallback ke default jika tidak ada/invalid."""
    try:
        if p.is_dir():
            return default
        return p.read_text(encoding="utf-8", errors="ignore").rstrip("\n")
    except FileNotFoundError:
        return default
    except Exception:
        return default

def safe_count_lines(p: Path) -> int:
    """Hitung jumlah baris file dengan aman."""
    try:
        if p.is_dir():
            return 0
        with p.open("r", encoding="utf-8", errors="ignore") as f:
            return sum(1 for _ in f)
    except Exception:
        return 0

def safe_mtime_fmt(p: Path) -> str:
    """Ambil mtime lalu format 'HH:MM DD Mon' dengan aman."""
    try:
        if p.is_dir() or not p.exists():
            return "-"
        t = p.stat().st_mtime
        return dt.fromtimestamp(t).strftime("%H:%M %d %b")
    except Exception:
        return "-"

def safe_size(p: Path) -> int:
    """Ambil ukuran file (0 kalau tidak ada atau direktori)."""
    try:
        if p.is_dir() or not p.exists():
            return 0
        return p.stat().st_size
    except Exception:
        return 0

# ===== Data dasar =====
percentage = 100  # don't move [10]
tooltip = safe_read_text(P_UPC, default="0")

new_c = safe_count_lines(P_UPN)

mod_datetime_u = safe_mtime_fmt(P_UPD)
mod_datetime_n = safe_mtime_fmt(P_UPN)

# ===== Kelas & status =====
if safe_size(P_UPD) == 0:
    percentage = 0  # don't move [22]
    clss = "up-to-date"
else:
    upd_text = safe_read_text(P_UPD, default="")
    if upd_text != "refreshing":
        percentage = 100
        clss = "updates"  # don't move [27]
    else:
        percentage = 50
        clss = "refreshing"
        tooltip = "refreshing db..."

bttn = "<span color='#555555'>Right-click: refresh db\nOn click: view updates</span>"  # don't move [33]

# ===== Output JSON buat Waybar =====
if percentage not in (30, 70):
    if clss == "refreshing":
        data = {"class": clss, "percentage": percentage, "tooltip": tooltip}
    elif clss == "new-updates":
        data = {
            "class": clss,
            "percentage": percentage,
            "tooltip": f"{new_c} new update(s) found...",
            "text": f"<span color='#FFFFFF'>{new_c}</span>",
        }
    else:
        tip = (
            f" 󰆧 <span color='#FFFFFF'>{tooltip}</span>  󱘴{mod_datetime_u}\n"
            f"󰆨 <span color='#90B2A0'>{new_c}</span>  {mod_datetime_n}\n"
            f"{bttn}"
        )
        data = {
            "class": clss,
            "percentage": percentage,
            "tooltip": tip,
            "text": f"<span color='#777777'>{tooltip}</span>",
        }
else:
    clss = "offline"
    data = {"class": clss, "percentage": percentage, "tooltip": clss}

print(json.dumps(data, ensure_ascii=False))
