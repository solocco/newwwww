#!/usr/bin/env bash
set -euo pipefail

UPD_DIR=/tmp/upd
mkdir -p "$UPD_DIR"

COUNT="$UPD_DIR/count"
UPD="$UPD_DIR/updates"
UPN="$UPD_DIR/new"
UPO="$UPD_DIR/old"
LOCK="$UPD_DIR/refresh.lock"

touch "$COUNT" "$UPD" "$UPN"

signal() {
  pkill -SIGRTMIN+9 waybar 2>/dev/null || true
}

cleanup() {
  rm -f "$LOCK"
  signal
}
trap cleanup EXIT

# ===== START REFRESH =====
touch "$LOCK"
signal

# ===== CHECK NETWORK =====
if ! ping -4 -c 1 -W 3 www.voidlinux.org >/dev/null 2>&1; then
  exit 0
fi

# ===== SAVE OLD UPDATES =====
[[ -s "$UPD" ]] && cp "$UPD" "$UPO" || > "$UPO"

# ===== FETCH UPDATES =====
xbps-install -Mnu | awk '/update/ {print $1}' > "$UPD"

# >>> BARU DI SINI count ditulis <<<
wc -l < "$UPD" > "$COUNT"

# ===== DETECT NEW =====
if [[ -s "$UPO" ]]; then
  comm -23 <(sort "$UPD") <(sort "$UPO") > "$UPN" || > "$UPN"
else
  cp "$UPD" "$UPN"
fi

signal
