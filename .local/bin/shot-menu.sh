#!/bin/sh
# Simple Screenshot menu (fuzzel + grim + slurp + wl-copy)

SHOT_DIR="$HOME/pictures/ScreenShots"
mkdir -p "$SHOT_DIR"

sel=$(printf "Region → Clipboard\nRegion → File\nFull Screen → Clipboard\nFull Screen → File\nExit\n" \
    | fuzzel --dmenu --prompt "Screenshot: ")

ts=$(date +%F_%H-%M-%S)

case "$sel" in
    "Region → Clipboard")
        slurp | grim -g - - | wl-copy -t image/png
        ;;
    "Region → File")
        slurp | grim -g - "$SHOT_DIR/shot-$ts.png"
        ;;
    "Full Screen → Clipboard")
        grim - | wl-copy -t image/png
        ;;
    "Full Screen → File")
        grim "$SHOT_DIR/shot-$ts.png"
        ;;
    *) exit ;;
esac

