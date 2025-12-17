#!/usr/bin/env bash

MODE="$1" # icon | value

TEMP=$(sensors | grep -m 1 'Package id 0' | awk '{print $4}' | tr -d '+°C')

if [[ -z "$TEMP" ]]; then
  if [[ "$MODE" == "icon" ]]; then
    printf '{"text":"","class":"unknown"}\n'
  else
    printf '{"text":"N/A°C","class":"unknown"}\n'
  fi
  exit 0
fi

TEMP_INT=$(printf "%.0f" "$TEMP")

if (( TEMP_INT >= 70 )); then
  CLASS="critical"
elif (( TEMP_INT >= 55 )); then
  CLASS="warm"
else
  CLASS="cool"
fi

if [[ "$MODE" == "icon" ]]; then
  printf '{"text":"","class":"%s"}\n' "$CLASS"
else
  printf '{"text":"%s°C","class":"value"}\n' "$TEMP_INT"
fi
