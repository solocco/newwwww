#!/usr/bin/env bash
# set-wallpaper.sh - Wrapper untuk set wallpaper via swaybg
# Usage: set-wallpaper.sh <image_path> [mode]

set -euo pipefail

IMAGE="$1"
MODE="${2:-fill}"
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/autostart/flavours-wall.log"

mkdir -p "$(dirname "$LOG")"

# Kill existing swaybg
pkill -x swaybg 2>/dev/null || true
sleep 0.1

# Log
printf '[%s] swaybg %s %s\n' "$(date '+%F %T')" "$MODE" "$IMAGE" >> "$LOG"

# Start swaybg
nohup swaybg -m "$MODE" -i "$IMAGE" >> "$LOG" 2>&1 &
