#!/bin/sh
# waybar-menu.sh — pilih waybar style via rofi
set -eu

# --- Dependencies ---
command -v rofi   >/dev/null 2>&1 || { echo "rofi not found.";   exit 1; }
command -v waybar >/dev/null 2>&1 || { echo "waybar not found."; exit 1; }

# --- Config ---
WAYBAR_DIR="${HOME}/.config/waybar/mango"
ROFI_THEME="${HOME}/.config/rofi/waybar-menu.rasi"
IGNORED="backup"

# --- Notification Config ---
APP_NAME="Waybar"
NOTIFY_ID=7775

# --- Notification Functions ---
have() {
  command -v "$1" >/dev/null 2>&1
}

notify_user() {
  msg="$1"
  if have dunstify; then
    dunstify -a "$APP_NAME" -r "$NOTIFY_ID" -u low "$msg"
  else
    notify-send -a "$APP_NAME" -u low \
      -h string:x-canonical-private-synchronous:"waybar-style" \
      "$msg"
  fi
}

# --- Helpers ---
get_current_style() {
  style_css="${WAYBAR_DIR}/style.css"
  
  if [ ! -e "$style_css" ]; then
    echo "None"
    return
  fi
  
  if [ -L "$style_css" ]; then
    target="$(readlink -f "$style_css")"
    basename "$(dirname "$target")"
  else
    echo "Unknown"
  fi
}

get_styles() {
  [ -d "$WAYBAR_DIR" ] || return
  
  for dir in "$WAYBAR_DIR"/*; do
    [ -d "$dir" ] || continue
    
    name="$(basename "$dir")"
    
    # Skip ignored
    echo "$IGNORED" | grep -qw "$name" && continue
    
    # Check if style.css and config.jsonc exist
    [ -f "$dir/style.css" ] && [ -f "$dir/config.jsonc" ] && echo "$name"
  done | sort
}

apply_style() {
  style="$1"
  
  style_src="${WAYBAR_DIR}/${style}/style.css"
  style_dst="${WAYBAR_DIR}/style.css"
  
  config_src="${WAYBAR_DIR}/${style}/config.jsonc"
  config_dst="${WAYBAR_DIR}/config.jsonc"
  
  # Validate files exist
  if [ ! -f "$style_src" ] || [ ! -f "$config_src" ]; then
    notify_user "Style files not found"
    exit 1
  fi
  
  # Remove old symlinks
  [ -e "$style_dst" ] || [ -L "$style_dst" ] && rm -f "$style_dst"
  [ -e "$config_dst" ] || [ -L "$config_dst" ] && rm -f "$config_dst"
  
  # Create new symlinks (relative path lebih aman)
  ln -sf "${style}/style.css" "$style_dst"
  ln -sf "${style}/config.jsonc" "$config_dst"
  
  # Restart waybar dengan proper process handling
  pkill -x waybar 2>/dev/null || true
  sleep 0.5
  
  # Start waybar in background properly
  config_path="${WAYBAR_DIR}/config.jsonc"
  style_path="${WAYBAR_DIR}/style.css"
  
  # Method 1: using sh -c for proper variable expansion
  sh -c "waybar -c '$config_path' -s '$style_path' >/dev/null 2>&1 &"
  
  # Wait a bit and verify
  sleep 0.3
  if pgrep -x waybar >/dev/null; then
    notify_user "Layout Applied: $style"
  else
    notify_user "Failed to start waybar"
  fi
}

# --- Main ---
current="$(get_current_style)"
styles="$(get_styles)"

if [ -z "$styles" ]; then
  notify_user "No layouts found"
  exit 1
fi

# Show menu
pick="$(printf '%s\n' "$styles" | rofi -dmenu -i -p "Select Layout" -theme "$ROFI_THEME")" || true
[ -z "$pick" ] && exit 0

# Apply selected style
apply_style "$pick"
