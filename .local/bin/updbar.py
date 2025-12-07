#!/usr/bin/python
# -*- coding: utf-8 -*-

from datetime import datetime as dt
from pathlib import Path
import json
import shutil

# ===== Paths =====
UPD_DIR = Path("/tmp/upd")
UPD_DIR.mkdir(parents=True, exist_ok=True)

upc = UPD_DIR / "count"
upd = UPD_DIR / "updates"
upn = UPD_DIR / "new"
lock = UPD_DIR / "refresh.lock"

# Pastikan file-file dasar ada (kalau kebetulan berupa folder, hapus dulu)
for file_path in [upc, upd, upn]:
    if file_path.exists() and file_path.is_dir():
        shutil.rmtree(str(file_path))
    if not file_path.exists():
        file_path.touch()

# Pastikan count file punya nilai
if upc.is_dir():
    shutil.rmtree(str(upc))
    upc.touch()
    upc.write_text("0")
elif not upc.exists() or upc.stat().st_size == 0:
    upc.write_text("0")

def safe_read_text(p: Path, default: str = "") -> str:
    try:
        if not p.exists():
            p.touch()
            return default
        if p.is_dir():
            return default
        return p.read_text(encoding="utf-8", errors="ignore").rstrip("\n")
    except Exception:
        return default

# Spinner frames
SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

# ===== Logic sederhana =====
is_refreshing = lock.exists()

if is_refreshing:
    # cuma spinner
    idx = int(dt.now().timestamp() * 5) % len(SPINNER_FRAMES)
    frame = SPINNER_FRAMES[idx]

    data = {
        "class": "refreshing",
        # percentage bebas, asal konsisten sama CSS / format-icons-mu
        "percentage": 50,
        # tooltip dikosongin biar ga ada tulisan "refreshing" / "update"
        "tooltip": "",
        "text": f"<span color='#777777'>{frame}</span>",
    }
else:
    # lagi idle: modul kosong (ga ada icon/teks)
    data = {
        "class": "idle",
        "percentage": 0,
        "tooltip": "",
        "text": "",
    }

print(json.dumps(data, ensure_ascii=False))
