#!/usr/bin/env bash
# Volume control for Wayland + fnott (wpctl only, no icons) with progress bar
set -euo pipefail

APP_NAME="Volume"
NOTIFY_ID=7772
STEP="${STEP:-5}"   # percent step, override: STEP=10 ./volume-fnott.sh --inc
BAR_WIDTH="${BAR_WIDTH:-10}"  # length of progress bar

have() { command -v "$1" >/dev/null 2>&1; }

notify_user() {
  local msg="$1"
  if have dunstify; then
    dunstify -a "$APP_NAME" -r "$NOTIFY_ID" -u low "$msg"
  else
    notify-send -a "$APP_NAME" -u low \
      -h string:x-canonical-private-synchronous:"sys-volume" \
      "$msg"
  fi
}

# Return integer percent 0..100
get_volume() {
  # "Volume: 0.55 [MUTED]" or "Volume: 0.55"
  local line
  line="$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
  awk '{print int($2*100+0.5)}' <<<"$line"
}

is_muted() {
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "\[MUTED\]"
}

unmute_sink() {
  wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
}

# Build a unicode progress bar like "█████░░░░░"
make_bar() {
  local pct="$1" width="$2"
  # round to nearest cell
  local filled=$(( (pct * width + 50) / 100 ))
  local empty=$(( width - filled ))
  local out=""
  for ((i=0;i<filled;i++));  do out+="█"; done
  for ((i=0;i<empty;i++));   do out+="░"; done
  printf "%s" "$out"
}

show_status() {
  local v pct bar
  v="$(get_volume)"
  pct="$v"
  bar="$(make_bar "$pct" "$BAR_WIDTH")"
  if is_muted; then
    notify_user "Mute  [${bar}]"
  else
    notify_user "Volume: ${pct}%  [${bar}]"
  fi
}

change_volume() {
  local op="$1"  # + or -
  unmute_sink
  # clamp at 100% (1.0)
  if [[ "$op" == "+" ]]; then
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "${STEP}%+"
  else
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "${STEP}%-"
  fi
  show_status
}

toggle_mute() {
  if is_muted; then
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
    show_status
  else
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
    notify_user "Mute"
  fi
}

toggle_mic() {
  # Toggle default source mute
  if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "\[MUTED\]"; then
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
    notify_user "Microphone ON"
  else
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
    notify_user "Microphone OFF"
  fi
}

case "${1:-}" in
  --get)        get_volume ;;
  --inc)        change_volume "+" ;;
  --dec)        change_volume "-" ;;
  --toggle)     toggle_mute ;;
  --toggle-mic) toggle_mic ;;
  *)            show_status ;;
esac

