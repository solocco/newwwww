#!/usr/bin/env bash
#
# This script depends on: rofi jq python

set -euo pipefail

DIR=/tmp/upd
UPD="$DIR/updates"
UPN="$DIR/new"
UPO="$DIR/old"
PRT="$DIR/pretty"
COUNT="$DIR/count"
PID="$HOME/.config/service/updatenotif/supervise/pid"

# --- rofi theme path (point to your theme) ---
THEME="$HOME/.config/rofi/update-void.rasi"

# Pastikan direktori dan file ada
mkdir -p "$DIR"
touch "$UPD" "$UPN" "$UPO" "$PRT"

# Pastikan COUNT adalah file, bukan direktori
if [[ -d "$COUNT" ]]; then
    rm -rf "$COUNT"
fi
[[ ! -f "$COUNT" ]] && echo "0" > "$COUNT"

# Helper: hitung baris aman (fallback 0 kalau file tak ada)
line_count() {
  local f=${1:-}
  [[ -f "$f" ]] || { echo 0; return; }
  awk 'END{print NR}' "$f" 2>/dev/null || echo 0
}

# status text
STT="-"
if [[ -f "$PID" ]] && [[ -r "$PID" ]]; then
    STT="ó°»¾ $(<"$PID")"
fi

# if updater is refreshing, exit quietly
if [[ -f "$UPD" ]] && [[ "$( < "$UPD" 2>/dev/null || echo "")" == "refreshing" ]]; then
  exit 0
fi

# avoid duplicate rofi
if pidof rofi >/dev/null 2>&1; then
  pkill -x rofi || true
  exit 0
fi

# rofi wrapper: always use update-void.rasi if exists, else minimal fallback
_rofi() {
  local prompt="$1"
  if [[ -f "$THEME" ]]; then
    timeout 60 rofi -dmenu -p "$prompt" -theme "$THEME" || true
  else
    # Fallback theme (very minimal) jika update-void.rasi tidak ditemukan
    timeout 60 rofi -dmenu -p "$prompt" -theme-str '
      * { font: "monospace 12"; }
      window { width: 600px; }
    ' || true
  fi
}

# main
if [[ -s "$UPD" ]]; then
  # Ada daftar updates (+ pretty jika tersedia)
  c_upd="$(line_count "$UPD")"
  c_new="$(line_count "$UPN")"

  # Tulis count ke file (bukan direktori)
  printf '%s\n' "$c_upd" > "$COUNT"

  if [[ -s "$PRT" ]]; then
    _rofi "[ó°†§ $c_upd |ó°†¨ $c_new |$STT] " < "$PRT" > /dev/null
  else
    printf 'Updates available (no pretty list)\n' | _rofi "[ó°†§ $c_upd |ó°†¨ $c_new |$STT] " > /dev/null
  fi
else
  # Tidak ada file UPD atau kosong
  cls="unknown"
  if [[ -f "$HOME/.local/bin/updbar.py" ]]; then
    cls="$(python "$HOME/.local/bin/updbar.py" 2>/dev/null | jq -r .class 2>/dev/null || echo unknown)"
  fi
  
  if [[ "$cls" == "offline" ]]; then
    if [[ -s "$UPO" ]]; then
      _rofi "[offline |$STT] " < "$UPO" > /dev/null
    else
      printf 'Right-click to refresh\n' | _rofi "[offline |$STT] " > /dev/null
    fi
  else
    printf 'Void is up-to-date\n' | _rofi "[$STT] " > /dev/null
  fi
fi

# Source code: "https://codeberg.org/dogknowsnx/dotfiles/scripts"
