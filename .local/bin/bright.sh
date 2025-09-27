#!/usr/bin/env bash
# Brightness control for Wayland + fnott (light, no icons) with progress bar
set -euo pipefail

APP_NAME="Brightness"
NOTIFY_ID=7771
STEP="${STEP:-5}"            # percent step (override: STEP=10 brightness-fnott.sh --inc)
BAR_WIDTH="${BAR_WIDTH:-10}" # progress bar cells

have() { command -v "$1" >/dev/null 2>&1; }

notify_user() {
  local msg="$1"
  if have dunstify; then
    dunstify -a "$APP_NAME" -r "$NOTIFY_ID" -u low "$msg"
  else
    notify-send -a "$APP_NAME" -u low \
      -h string:x-canonical-private-synchronous:"sys-brightness" \
      "$msg"
  fi
}

# Return integer percent 0..100
get_brightness() {
  local val
  val="$(light -G 2>/dev/null || echo 0)"
  printf "%d\n" "$(awk -v v="$val" 'BEGIN { printf("%.0f", v) }')"
}

# Build a unicode progress bar like "█████░░░░░"
make_bar() {
  local pct="$1" width="$2"
  local filled=$(( (pct * width + 50) / 100 ))
  (( filled > width )) && filled="$width"
  (( filled < 0 )) && filled=0
  local empty=$(( width - filled ))
  local out=""
  for ((i=0;i<filled;i++)); do out+="█"; done
  for ((i=0;i<empty;i++));  do out+="░"; done
  printf "%s" "$out"
}

show_status() {
  local b bar
  b="$(get_brightness)"
  bar="$(make_bar "$b" "$BAR_WIDTH")"
  notify_user "Brightness: ${b}%  [${bar}]"
}

# Change brightness and show status
inc_brightness() {
  light -A "$STEP" || true
  show_status
}
dec_brightness() {
  light -U "$STEP" || true
  show_status
}

case "${1:-}" in
  --get) get_brightness ;;
  --inc) inc_brightness ;;
  --dec) dec_brightness ;;
  *)     show_status ;;
esac
