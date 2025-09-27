#!/bin/sh
# Simple Network Manager menu (fuzzel + nmcli)
# Panggil fuzzel sama persis seperti flavours-menu.sh

set -eu

# --- deps ---
command -v nmcli  >/dev/null 2>&1 || { echo "nmcli not found";  exit 1; }
command -v fuzzel >/dev/null 2>&1 || { echo "fuzzel not found"; exit 1; }

# --- Config fuzzel (sama dgn flavours-menu) ---
DMENU_OPTS="--dmenu --prompt 'Menu:' --lines 12 --width 40"
MENU_INI="$HOME/.config/fuzzel/fuzzel-menu.right.ini"

fz() {
  # $1 = prompt
  fuzzel --config "$MENU_INI" $DMENU_OPTS --prompt "$1"
}

# --- helpers ---
wifi_dev() {
  nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi"{print $1; exit}'
}

connect_wifi() {
  nmcli dev wifi rescan >/dev/null 2>&1 || true
  sleep 0.2
  sel="$(
    nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list \
    | awk -F: '{s=$1; if(s=="")s="<Hidden>"; sig=$2; sec=$3; if(sec=="")sec="--"; printf "%s | %s | %s\n",s,sig,sec}' \
    | sort -t'|' -k2,2nr \
    | fz "Select Wi-Fi:"
  )" || true
  [ -z "${sel:-}" ] && return
  ssid="$(printf "%s" "$sel" | cut -d'|' -f1 | sed 's/[[:space:]]*$//')"
  sec="$( printf "%s" "$sel" | cut -d'|' -f3 | sed 's/^[[:space:]]*//')"

  if [ "$sec" = "--" ]; then
    nmcli dev wifi connect "$ssid"
  else
    pw="$(printf "" | fuzzel --config "$MENU_INI" $DMENU_OPTS --prompt "Password for $ssid:" --password)" || true
    [ -z "${pw:-}" ] && return
    nmcli dev wifi connect "$ssid" password "$pw"
  fi
}

disconnect_wifi() {
  dev="$(wifi_dev || true)"
  [ -z "${dev:-}" ] && return
  conn="$(nmcli -t -f NAME,DEVICE connection show --active | awk -F: -v d="$dev" '$2==d{print $1; exit}')"
  [ -n "${conn:-}" ] && nmcli con down "$conn" || true
}

forget_wifi() {
  sel="$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="802-11-wireless"{print $1}' | fz "Forget Wi-Fi:")" || true
  [ -n "${sel:-}" ] && nmcli con delete "$sel" || true
}

status_wifi() {
  out="$(nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1=="yes"{print "Wi-Fi: "$2}')"
  [ -z "${out:-}" ] && out="Wi-Fi: Not connected"
  printf "%s\n" "$out" | fz "Status" >/dev/null
}

# --- main ---
choice="$(printf "Connect Wi-Fi\nDisconnect Wi-Fi\nForget Wi-Fi\nStatus\nExit\n" | fz "Network:")" || true
case "$choice" in
  "Connect Wi-Fi")    connect_wifi ;;
  "Disconnect Wi-Fi") disconnect_wifi ;;
  "Forget Wi-Fi")     forget_wifi ;;
  "Status")           status_wifi ;;
  *) exit 0 ;;
esac
