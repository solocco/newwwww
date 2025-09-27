#!/bin/sh
# Rofi Quick Settings (grid 2 kolom) — IKON Nerd Font gede di atas, label di bawah
# Jalankan dgn:
#   rofi -show qset \
#     -modi qset:~/.local/bin/quick-settings-rofi-nerd.sh \
#     -theme ~/.config/rofi/themes/quick-tiles-2col-nerd.rasi

set -eu

has(){ command -v "$1" >/dev/null 2>&1; }

# ---- status helpers ----
wifi_stat(){ has nmcli && nmcli radio wifi 2>/dev/null | tr '[:lower:]' '[:upper:]' || echo "N/A"; }
bt_stat(){ has bluetoothctl && bluetoothctl show 2>/dev/null | awk '/Powered:/ {print toupper($2); exit}' || echo "N/A"; }
nl_stat(){ pgrep -x wlsunset >/dev/null 2>&1 && echo "ON" || echo "OFF"; }
vol_stat(){
  if has pactl; then
    m=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print toupper($2)}')
    v=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk -F'/' '{gsub(/ /,""); print $2}' | head -n1)
    printf "%s%s" "$v" "$( [ "$m" = "YES" ] && printf " (MUTED)" )"
  else echo "N/A"; fi
}
bright_stat(){ has light && printf '%s%%' "$(printf '%.0f' "$(light -G 2>/dev/null || echo 0)")" || echo "N/A"; }

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/autostart"
LAST_THEME="$STATE_DIR/last_theme"
LAST_WALL="$STATE_DIR/last_wall"
theme_stat(){ [ -s "$LAST_THEME" ] && cat "$LAST_THEME" || echo "-"; }

# ---- actions ----
wifi_toggle(){ has nmcli && { [ "$(wifi_stat)" = "ENABLED" ] && nmcli radio wifi off || nmcli radio wifi on; }; }
bt_toggle(){   has bluetoothctl && { [ "$(bt_stat)" = "YES" ] && printf 'power off\nquit\n' | bluetoothctl >/dev/null || printf 'power on\nquit\n' | bluetoothctl >/dev/null; }; }
nl_toggle(){   pgrep -x wlsunset >/dev/null && pkill -x wlsunset || (wlsunset -T 6500 -t 5500 -l -6.2 -L 106.8 >/dev/null 2>&1 &); }
vol_up(){      has pactl && pactl set-sink-volume @DEFAULT_SINK@ +5%; }
vol_down(){    has pactl && pactl set-sink-volume @DEFAULT_SINK@ -5%; }
vol_mute(){    has pactl && pactl set-sink-mute   @DEFAULT_SINK@ toggle; }
mic_mute(){    has pactl && pactl set-source-mute @DEFAULT_SOURCE@ toggle; }
bright_up(){   has light && light -A 10; }
bright_down(){ has light && light -U 10; }
waybar_restart(){ pkill -x waybar >/dev/null 2>&1 || true; waybar >/dev/null 2>&1 & }
theme_menu(){ [ -x "$HOME/.local/bin/flavours-menu.sh" ] && "$HOME/.local/bin/flavours-menu.sh" || true; }
reload_last(){
  has flavours && [ -s "$LAST_THEME" ] && flavours apply "$(cat "$LAST_THEME")" >/dev/null 2>&1 || true
  if [ -s "$LAST_WALL" ] && [ -f "$(cat "$LAST_WALL")" ]; then
    pkill -x swaybg 2>/dev/null || true
    swaybg -m fill -i "$(cat "$LAST_WALL")" >/dev/null 2>&1 &
  fi
}

# ---- rofi script-mode dispatch ----
if [ $# -gt 0 ]; then
  case "${ROFI_INFO:-$1}" in
    wifi) wifi_toggle ;;
    bt) bt_toggle ;;
    night) nl_toggle ;;
    vol_up) vol_up ;;
    vol_dn) vol_down ;;
    vol_mute) vol_mute ;;
    mic_mute) mic_mute ;;
    br_up) bright_up ;;
    br_dn) bright_down ;;
    theme) theme_menu ;;
    reload) reload_last ;;
    waybar) waybar_restart ;;
  esac
  exit 0
fi

# ---- printer: 2-baris (ikon gede + label) pakai Pango markup ----
# gunakan glyph Nerd Font. Sesuaikan kalau mau.
GLYPH_SIZE="${GLYPH_SIZE:-38}"     # ukuran ikon (pt-ish)
LABEL_SIZE="${LABEL_SIZE:-9}"      # ukuran label kecil

tile() {
  # $1 glyph, $2 label, $3 id
  printf "<span font='Iosevka Nerd Font' size='%spt'>%s</span>\n<span size='%spt'>%s</span>\0info\x1f%s\n" \
    "$GLYPH_SIZE" "$1" "$LABEL_SIZE" "$2" "$3"
}

WIFI="$(wifi_stat)"; BT="$(bt_stat)"; NL="$(nl_stat)"
VOL="$(vol_stat)";  BR="$(bright_stat)"; TH="$(theme_stat)"

tile ""  "Wi-Fi: $WIFI"                            "wifi"
tile "󰂯"  "Bluetooth: $( [ "$BT" = "YES" ] && echo ON || echo OFF )" "bt"
tile "󰖨"  "Night: $NL"                               "night"

tile ""  "Vol ↑ ($VOL)"                             "vol_up"
tile ""  "Vol ↓ ($VOL)"                             "vol_dn"
tile ""  "Vol Mute"                                 "vol_mute"
tile ""  "Mic Mute"                                  "mic_mute"

tile ""  "Bright ↑ ($BR)"                           "br_up"
tile ""  "Bright ↓ ($BR)"                           "br_dn"

tile "󰣇"  "Theme… ($TH)"                             "theme"
tile ""  "Reload Last"                               "reload"
tile "󰖡"  "Waybar"                                    "waybar"

exit 0
