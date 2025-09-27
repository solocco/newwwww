#!/bin/sh

LOG="/tmp/autostart.log"

# =========================
# Config
# =========================
AUDIO=true
MODE="swaybg-random"        # swaybg, swaybg-random, none
THEME_MODE="last"           # last, auto, fixed, none
THEME_NAME="gruvbox-dark-medium"   # fallback kalau last/current tidak ada
CURSOR="Bibata-Modern-Ice"
WAYBAR_STYLE="none"         # stacking, tiling, none
UPDATE_SCAN=true

# Wallpaper lokal
DWALL="$HOME/pictures/walls/wall.jpg"   # fallback fixed
WALL_DIR="$HOME/pictures/walls"         # kumpulan wallpaper random

# Restore last wallpaper?
WALL_RESTORE=true           # true = pakai last_wall jika ada; false = selalu random baru

# =========================
# State files
# =========================
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/autostart"
LAST_THEME="$STATE_DIR/last_theme"
LAST_WALL="$STATE_DIR/last_wall"
mkdir -p "$STATE_DIR"

# =========================
# Tunggu Wayland siap (maks 10s)
# =========================
timeout=20
while { [ -z "${WAYLAND_DISPLAY:-}" ] || [ ! -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; } && [ "$timeout" -gt 0 ]; do
  sleep 0.5
  timeout=$((timeout - 1))
done

# =========================
# Env & Agents
# =========================
dbus-update-activation-environment --all >>"$LOG" 2>&1 &
/usr/libexec/polkit-gnome-authentication-agent-1 >>"$LOG" 2>&1 &

# =========================
# Monitor layout
# =========================
PRIMARY_OUTPUT="$(wlr-randr 2>/dev/null | awk '/^.* connected/ {print $1; exit}')"
if [ -n "$PRIMARY_OUTPUT" ]; then
  wlr-randr --output "$PRIMARY_OUTPUT" --on --pos 0,0 --transform normal --adaptive-sync enabled >>"$LOG" 2>&1 &
  wait
else
  echo "No connected outputs detected by wlr-randr" >>"$LOG"
fi

# =========================
# Process Management
# =========================
for p in flavours mpvpaper swaybg fnott wlsunset cliphist; do
  pkill -x "$p" >>"$LOG" 2>&1 || :
done

# =========================
# Audio (opsional)
# =========================
if [ "$AUDIO" = true ]; then
  for p in pipewire wireplumber pipewire-pulse; do pkill -x "$p" >>"$LOG" 2>&1 || :; done
  pipewire >>"$LOG" 2>&1 &
  sleep 1
  wireplumber >>"$LOG" 2>&1 &
  pipewire-pulse >>"$LOG" 2>&1 &
fi

# =========================
# OpenRGB (opsional)
# =========================
if command -v openrgb >/dev/null 2>&1; then
  openrgb --server -p pureWhite >>"$LOG" 2>&1 &
else
  echo "OpenRGB not found" >>"$LOG"
fi

# =========================
# Helpers
# =========================
ensure_image() {
  # $1 = path file yang akan dipakai swaybg
  if [ ! -s "$1" ]; then
    if [ -f "$DWALL" ]; then
      # kalau target bukan DWALL dan belum ada, pakai fallback DWALL
      echo "ensure_image: $1 missing, use DWALL=$DWALL" >>"$LOG"
      printf '%s\n' "$DWALL"
      return 0
    elif command -v convert >/dev/null 2>&1; then
      # bikin solid fallback di DWALL lalu pakai itu
      mkdir -p "$(dirname "$DWALL")"
      convert -size 1920x1080 xc:'#1d2021' "$DWALL"
      echo "Fallback solid created at $DWALL" >>"$LOG"
      printf '%s\n' "$DWALL"
      return 0
    else
      echo "No valid wallpaper and no ImageMagick; background may be black." >>"$LOG"
      printf '%s\n' "$1"
      return 0
    fi
  fi
  printf '%s\n' "$1"
}

apply_swaybg() {
  img="$1"
  pkill -x swaybg >>"$LOG" 2>&1 || :
  # Full screen proporsional (bisa crop jika rasio beda)
  nohup swaybg -i "$img" -m fill >>"$LOG" 2>&1 &
}

pick_random_wall() {
  find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | shuf -n1
}

set_last_wall() {
  # Simpan path wall terakhir (atomik)
  [ -n "${1:-}" ] || return 0
  tmp_w="$(mktemp "$STATE_DIR/.last_wall.XXXXXX")"
  printf '%s\n' "$1" > "$tmp_w" && mv -f "$tmp_w" "$LAST_WALL"
}

get_last_wall() {
  [ -s "$LAST_WALL" ] || return 1
  awk 'NF{print; exit}' "$LAST_WALL"
}

# =========================
# Main Wallpaper
# =========================
case "$MODE" in
  swaybg-random)
    if [ "$WALL_RESTORE" = true ]; then
      lw="$(get_last_wall || true)"
      if [ -n "${lw:-}" ] && [ -f "$lw" ]; then
        echo "Restore last_wall: $lw" >>"$LOG"
        SEL="$lw"
      else
        SEL="$(pick_random_wall)"
      fi
    else
      SEL="$(pick_random_wall)"
    fi
    [ -z "${SEL:-}" ] && SEL="$DWALL"
    SEL="$(ensure_image "$SEL")"
    apply_swaybg "$SEL"
    set_last_wall "$SEL"
    ;;
  swaybg)
    SEL="$(ensure_image "$DWALL")"
    apply_swaybg "$SEL"
    set_last_wall "$SEL"
    ;;
  none)
    ;;
  *)
    echo "Unknown MODE: $MODE" >>"$LOG"
    ;;
esac

# =========================
# Theme
# =========================
configure_theme() {
  get_last_theme() {
    if [ -s "$LAST_THEME" ]; then
      awk 'NF{print; exit}' "$LAST_THEME"
    else
      flavours current 2>/dev/null | awk 'NF{print; exit}'
    fi
  }

  case "$THEME_MODE" in
    last)
      LT="$(get_last_theme)"
      if [ -n "$LT" ]; then
        echo "Applying last theme: $LT" >>"$LOG"
        flavours apply "$LT" >>"$LOG" 2>&1 &
      else
        echo "No last theme found; fallback to THEME_NAME=$THEME_NAME" >>"$LOG"
        flavours apply "$THEME_NAME" >>"$LOG" 2>&1 &
      fi
      ;;
    auto)
      # generate dari DWALL (atau dari $SEL kalau mau—tinggal ganti path)
      SRC="${SEL:-$DWALL}"
      if [ -f "$SRC" ]; then
        flavours generate dark "$SRC" >>"$LOG" 2>&1
        flavours apply generated >>"$LOG" 2>&1 &
      fi
      ;;
    fixed)
      flavours apply "$THEME_NAME" >>"$LOG" 2>&1 &
      ;;
    none) ;;
  esac
}
configure_theme

# =========================
# Waybar
# =========================
configure_waybar() {
  case "$WAYBAR_STYLE" in
    stacking)
      pkill -x waybar >>"$LOG" 2>&1 || :
      waybar -c "$HOME/.config/waybar/config" -s "$HOME/.config/waybar/style.css" >>"$LOG" 2>&1 &
      ;;
    tiling)
      pkill -x waybar >>"$LOG" 2>&1 || :
      waybar -c "$HOME/.config/waybar/tiling-config" -s "$HOME/.config/waybar/style.css" >>"$LOG" 2>&1 &
      ;;
    none) ;;
  esac
}
configure_waybar

# =========================
# Cursor
# =========================
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR" >>"$LOG" 2>&1 &
seat seat0 xcursor_theme "$CURSOR" >>"$LOG" 2>&1 &

# =========================
# Extras
# =========================
fnott >>"$LOG" 2>&1 &
# Koordinat Jakarta: -6.2, 106.8
wlsunset -T 6500 -t 5500 -l -6.2 -L 106.8 >>"$LOG" 2>&1 &
wl-paste --watch cliphist store -max-items 100 >>"$LOG" 2>&1 &

# =========================
# Update Scan (opsional)
# =========================
if [ "$UPDATE_SCAN" = true ]; then
  sleep 2
  "$HOME/.local/bin/updtscan" >>"$LOG" 2>&1 &
fi

