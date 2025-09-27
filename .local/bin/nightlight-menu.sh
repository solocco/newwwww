#!/bin/sh
# Nightlight toggle menu (fuzzel + wlsunset)

set -eu

command -v fuzzel   >/dev/null 2>&1 || { echo "fuzzel not found"; exit 1; }
command -v wlsunset >/dev/null 2>&1 || { echo "wlsunset not found"; exit 1; }

DMENU_OPTS="--dmenu --lines 6 --width 20"
MENU_INI="$HOME/.config/fuzzel/fuzzel-menu.right.ini"

fz() { fuzzel --config "$MENU_INI" $DMENU_OPTS --prompt "Nightlight:"; }

choice="$(printf "On\nOff\nExit\n" | fz)" || true
case "$choice" in
  "On")
    pkill -x wlsunset 2>/dev/null || true
    # jalankan dengan konfigurasi custom
    wlsunset -T 6500 -t 5000 -l -6.2 -L 106.8 >/dev/null 2>&1 &
    notify-send "Nightlight" "Enabled (6500K→5000K)"
    ;;
  "Off")
    pkill -x wlsunset 2>/dev/null || true
    notify-send "Nightlight" "Disabled"
    ;;
  *) exit 0 ;;
esac
