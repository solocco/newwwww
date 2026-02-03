#!/usr/bin/env bash
# restore-theme.sh - Restore last theme and wallpaper on login

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/autostart"
LAST_THEME="$STATE_DIR/last_theme"
LAST_VARIANT="$STATE_DIR/last_variant"
LAST_WALL="$STATE_DIR/last_wall"
LOG="$STATE_DIR/flavours-wall.log"
WALL_MODE="${WALL_MODE:-fill}"

# Wait for compositor to be ready
sleep 2

# Restore theme
if [ -f "$LAST_THEME" ]; then
    theme="$(cat "$LAST_THEME")"
    variant="$(cat "$LAST_VARIANT" 2>/dev/null || echo "dark")"
    
    # Determine full theme name
    if [ "$variant" = "light" ]; then
        # Try common light suffixes
        for suffix in "-light" "-dawn"; do
            if flavours list 2>/dev/null | grep -qw "${theme}${suffix}"; then
                theme="${theme}${suffix}"
                break
            fi
        done
    fi
    
    echo "[$(date '+%F %T')] Restoring theme: $theme" >> "$LOG"
    flavours apply "$theme" >> "$LOG" 2>&1 || true
fi

# Restore wallpaper
if [ -f "$LAST_WALL" ]; then
    wall="$(cat "$LAST_WALL")"
    
    if [ -n "$wall" ] && [ -f "$wall" ]; then
        echo "[$(date '+%F %T')] Restoring wallpaper: $wall" >> "$LOG"
        
        # Kill existing swaybg
        pkill -x swaybg 2>/dev/null || true
        sleep 0.1
        
        # Start swaybg
        nohup swaybg -m "$WALL_MODE" -i "$wall" >> "$LOG" 2>&1 &
    fi
fi
