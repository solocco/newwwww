#!/bin/sh
# flavours-menu.sh — pilih flavour via fuzzel (nama cantik Title Case),
# apply flavours, restart fnott, set wallpaper pakai swaybg (fill),
# dan simpan state terakhir.

set -eu

# --- Dependencies ---
command -v flavours >/dev/null 2>&1 || { echo "flavours not found."; exit 1; }
command -v fuzzel   >/dev/null 2>&1 || { echo "fuzzel not found.";   exit 1; }
command -v swaybg   >/dev/null 2>&1 || { echo "swaybg not found.";   exit 1; }

# --- Config ---
DMENU_OPTS="--dmenu --prompt 'Flavour:' --lines 12 --width 40"
WALL_DIR="${WALL_DIR:-$HOME/pictures/walls}"
MAP_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/flavours/walls.map"

# >>> Default pakai fill (proporsional, bisa crop kalau rasio beda)
WALL_MODE="${WALL_MODE:-fill}"

MENU_INI="${MENU_INI:-$HOME/.config/fuzzel/fuzzel-menu.right.ini}"

# --- State & Log ---
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/autostart"
LAST_THEME="$STATE_DIR/last_theme"
LAST_WALL="$STATE_DIR/last_wall"
LOG="$STATE_DIR/flavours-wall.log"
mkdir -p "$STATE_DIR"
: > "$LOG" 2>/dev/null || true

# --- Helpers: Title Case <-> normal-name ---
to_title_case() {
  printf '%s' "$1" \
  | tr '_-' ' ' \
  | awk '{
      for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));
      print
    }'
}

normalize_scheme() {
  printf '%s' "$1" \
  | tr '[:upper:]' '[:lower:]' \
  | tr ' _' '-'
}

# --- File picking ---
first_image_from_pattern() {
  for pat in $*; do
    for f in $pat; do
      [ -e "$f" ] || continue
      if [ -d "$f" ]; then
        img="$(find "$f" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | shuf -n1 || true)"
        [ -n "${img:-}" ] && { printf '%s\n' "$img"; return; }
      elif [ -f "$f" ]; then
        printf '%s\n' "$f"; return
      fi
    done
  done
}

resolve_wall_for_flavour() {
  scheme="$1"
  if [ -f "$MAP_FILE" ]; then
    map_path="$(awk -v s="$scheme" '($1==s){$1=""; sub(/^[ \t]+/,""); print; exit}' "$MAP_FILE" 2>/dev/null || true)"
    if [ -n "${map_path:-}" ]; then
      img="$(first_image_from_pattern "$map_path")"
      [ -n "${img:-}" ] && { printf '%s\n' "$img"; return; }
    fi
  fi

  family="$(printf '%s' "$scheme" | cut -d- -f1 | tr '[:upper:]' '[:lower:]')"
  case "$scheme" in
    *dark*|*Dark*|*DARK*) tone=dark ;;
    *light*|*Light*|*LIGHT*) tone=light ;;
    *) tone=any ;;
  esac

  candidates=""
  candidates="$candidates \"$WALL_DIR/$scheme\" \"$WALL_DIR/$scheme/*\""
  [ "$tone" != "any" ] && candidates="$candidates \"$WALL_DIR/$family/$tone\" \"$WALL_DIR/$family/$tone/*\""
  candidates="$candidates \"$WALL_DIR/$family\" \"$WALL_DIR/$family/*\""
  [ "$tone" != "any" ] && candidates="$candidates \"$WALL_DIR/default-$tone\" \"$WALL_DIR/default/$tone\" \"$WALL_DIR/default/$tone/*\""
  candidates="$candidates \"$WALL_DIR/default\" \"$WALL_DIR/default/*\""

  img="$(eval "first_image_from_pattern $(printf '%s' "$candidates")" || true)"
  [ -n "${img:-}" ] && { printf '%s\n' "$img"; return; }
  printf '%s\n' ""
}

set_wall_with_swaybg() {
  img="$1"
  mode="$2"
  pkill -x swaybg 2>/dev/null || true
  printf '[%s] swaybg run: mode=%s img=%s\n' "$(date '+%F %T')" "$mode" "$img" >>"$LOG"
  nohup swaybg -m "$mode" -i "$img" >>"$LOG" 2>&1 &
}

save_state() {
  scheme_raw="$1"
  wall="$2"

  if command -v flavours >/dev/null 2>&1; then
    scheme="$(flavours current 2>/dev/null | awk 'NF{print; exit}')"
  fi
  [ -n "${scheme:-}" ] || scheme="$scheme_raw"

  tmp_t="$(mktemp "$STATE_DIR/.last_theme.XXXXXX")"
  printf '%s\n' "$scheme" > "$tmp_t" && mv -f "$tmp_t" "$LAST_THEME"

  if [ -n "$wall" ] && [ -f "$wall" ]; then
    tmp_w="$(mktemp "$STATE_DIR/.last_wall.XXXXXX")"
    printf '%s\n' "$wall" > "$tmp_w" && mv -f "$tmp_w" "$LAST_WALL"
  else
    : > "$LAST_WALL"
  fi
}

notify() {
  title="$1"; body="$2"
  command -v notify-send >/dev/null 2>&1 && notify-send "$title" "$body" || true
}

# --- Ambil daftar scheme ---
RAW_LIST="$(flavours list 2>/dev/null | tr ' ' '\n' | awk 'NF' | sort -u)"
[ -z "$RAW_LIST" ] && { echo "No flavours found."; exit 1; }

PRETTY_LIST="$(printf '%s\n' "$RAW_LIST" | while read -r s; do to_title_case "$s"; done)"

pick_pretty="$(printf '%s\n' "$PRETTY_LIST" | fuzzel --config "$MENU_INI" $DMENU_OPTS)" || true
[ -z "${pick_pretty:-}" ] && exit 0

scheme_real="$(normalize_scheme "$pick_pretty")"

if flavours apply "$scheme_real" 2>>"$LOG"; then
  pkill -x fnott 2>/dev/null || true
  nohup fnott >>"$LOG" 2>&1 &

  if command -v gsettings >/dev/null 2>&1; then
    case "$scheme_real" in
      *dark*|*Dark*|*DARK*)    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>>"$LOG" || true ;;
      *light*|*Light*|*LIGHT*) gsettings set org.gnome.desktop.interface color-scheme prefer-light 2>>"$LOG" || true ;;
    esac
  fi

  wall="$(resolve_wall_for_flavour "$scheme_real" || true)"
  if [ -n "${wall:-}" ] && [ -f "$wall" ]; then
    set_wall_with_swaybg "$wall" "$WALL_MODE"
    save_state "$scheme_real" "$wall"
    notify "Flavours" "Applied: $pick_pretty\nWallpaper: $(basename -- "$wall")\nMode: $WALL_MODE"
  else
    save_state "$scheme_real" ""
    notify "Flavours" "Applied: $pick_pretty\nWallpaper: TIDAK DITEMUKAN di $WALL_DIR"
  fi
else
  printf "Apply failed.\nCek templates & config.toml.\n" | fuzzel --dmenu --prompt "Error" >/dev/null
  exit 1
fi
