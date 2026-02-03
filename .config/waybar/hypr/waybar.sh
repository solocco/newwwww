#!/bin/bash

killall -9 waybar

waybar -c ~/.config/waybar/hypr/config.jsonc -s ~/.config/waybar/hypr/style.css &
