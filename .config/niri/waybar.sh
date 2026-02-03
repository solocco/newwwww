#!/bin/sh
if pgrep -x waybar > /dev/null; then
    pkill waybar
    sleep 0.3
fi
waybar -c ~/.config/waybar/niri/config-ver.jsonc -s ~/.config/waybar/niri/style-ver.css >/dev/null 2>&1 &
