#!/bin/sh
# Bluetooth menu (fuzzel + bluetoothctl)
# pakai config fuzzel-menu.right.ini

set -eu

command -v bluetoothctl >/dev/null 2>&1 || { echo "bluetoothctl not found"; exit 1; }
command -v fuzzel        >/dev/null 2>&1 || { echo "fuzzel not found"; exit 1; }

DMENU_OPTS="--dmenu --lines 12 --width 40"
MENU_INI="$HOME/.config/fuzzel/fuzzel-menu.right.ini"

fz() { fuzzel --config "$MENU_INI" $DMENU_OPTS --prompt "$1"; }
pick_mac() { awk -F'[[:space:]]*\\|[[:space:]]*' '{print $1}'; }

scan_connect() {
    printf "scan on\n" | bluetoothctl >/dev/null
    sleep 8
    macs="$(printf "devices\n" | bluetoothctl | awk '/^Device/{print $2 " | " $3}')"
    mac="$(printf "%s\n" "$macs" | fz "Select:" | pick_mac || true)"
    if [ -n "${mac:-}" ]; then
        echo -e "pair $mac\ntrust $mac\nconnect $mac\nquit" | bluetoothctl
    fi
    printf "scan off\n" | bluetoothctl >/dev/null
}

connect_paired() {
    mac="$(printf "paired-devices\n" | bluetoothctl | awk '/^Device/{print $2 " | " $3}' \
          | fz "Paired:" | pick_mac || true)"
    [ -n "${mac:-}" ] && echo -e "connect $mac\nquit" | bluetoothctl
}

disconnect_dev() {
    mac="$(printf "devices\n" | bluetoothctl | awk '/^Device/ && /Connected/{print $2 " | " $3}' \
          | fz "Disconnect:" | pick_mac || true)"
    [ -n "${mac:-}" ] && echo -e "disconnect $mac\nquit" | bluetoothctl
}

remove_dev() {
    mac="$(printf "paired-devices\n" | bluetoothctl | awk '/^Device/{print $2 " | " $3}' \
          | fz "Remove:" | pick_mac || true)"
    [ -n "${mac:-}" ] && echo -e "remove $mac\nquit" | bluetoothctl
}

trust_dev() {
    mac="$(printf "paired-devices\n" | bluetoothctl | awk '/^Device/{print $2 " | " $3}' \
          | fz "Trust:" | pick_mac || true)"
    [ -z "${mac:-}" ] && return
    echo -e "trust $mac\nquit" | bluetoothctl
    if bluetoothctl info "$mac" | grep -q "Trusted: yes"; then
        notify-send "Bluetooth" "Trusted $mac"
    else
        notify-send "Bluetooth" "Gagal trust $mac"
    fi
}

toggle_power() {
    pow="$(printf "show\n" | bluetoothctl | awk -F': ' '/Powered/{print $2}')"
    if [ "$pow" = "yes" ]; then
        echo -e "power off\nquit" | bluetoothctl
    else
        echo -e "power on\nquit" | bluetoothctl
    fi
}

toggle_agent() {
    # aktifkan agent default bila off
    ag="$(printf "show\n" | bluetoothctl | awk -F': ' '/Discoverable/{print $2}')"
    if [ "$ag" = "yes" ]; then
        echo -e "agent off\nquit" | bluetoothctl
    else
        echo -e "agent on\ndefault-agent\nquit" | bluetoothctl
    fi
}

show_status() {
    info="$(printf "show\nquit" | bluetoothctl)"
    printf "%s\n" "$info" | fz "Status" >/dev/null
}

# ---- main menu ----
choice="$(printf "Scan & Connect\nConnect Paired\nDisconnect\nRemove Device\nTrust Device\nToggle Power\nToggle Agent\nShow Status\nExit\n" \
          | fz "Bluetooth:")" || true

case "$choice" in
    "Scan & Connect") scan_connect ;;
    "Connect Paired") connect_paired ;;
    "Disconnect")     disconnect_dev ;;
    "Remove Device")  remove_dev ;;
    "Trust Device")   trust_dev ;;
    "Toggle Power")   toggle_power ;;
    "Toggle Agent")   toggle_agent ;;
    "Show Status")    show_status ;;
    *) exit 0 ;;
esac
