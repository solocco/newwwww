#!/usr/bin/env bash

# Pastikan direktori utama ada
UPD_DIR=/tmp/upd
mkdir -p "$UPD_DIR"

UPC="$UPD_DIR/count"
UPI="$UPD_DIR/installed"
UPD="$UPD_DIR/updates"
UPN="$UPD_DIR/new"
UPO="$UPD_DIR/old"
PRT="$UPD_DIR/pretty"
UBR=$HOME/.local/bin/updbar.py

# Inisialisasi file-file yang diperlukan
touch "$UPI" "$UPN" "$UPO" "$PRT" "$UPD"
echo 0 > "$UPC"

_chck_upd() {
	xbps-install -Mnu | awk '/update/ { print $1 }'
}

_sed_pc() {
	local PC=percentage
	if [[ -f "$UBR" ]]; then
		sed -i -e "10s/${PC}\ =\ [0-9\"]*/${PC}\ =\ $1/" \
			   -e "22s/${PC}\ =\ [0-9\"]*/${PC}\ =\ $2/" "$UBR"
	fi
}

_sed_cl() {
	if [[ -f "$UBR" ]]; then
		sed -i "27s/clss =\ .*\ #/clss\ =\ \"$1\"\ #/" "$UBR"
	fi
}

_sed_nw() {
	if [[ ! -f "$UPN" ]] || [[ ! -f "$UPD" ]]; then
		return
	fi
	
	local IFS=$'\n'
	for i in $(< "$UPN")
		do
			sed -i "s/$i.*/&\ \ \ NEW/" "$UPD" 2>/dev/null || true
		done

	sed -i "s/NEW.*/NEW\ \ /g" "$UPD" 2>/dev/null || true
}

_mkp() {
	if [[ -f "$UPD" ]] && [[ -f "$UPI" ]]; then
		paste -d' ' "$UPD" "$UPI" > "$PRT"
	fi
}

_sig() {
	pkill -x -SIGRTMIN+9 waybar 2>/dev/null || true
}

# Pastikan python script ada sebelum dijalankan
if [[ -f "$UBR" ]] && [[ "$(python "$UBR" 2>/dev/null | jq -r .class 2>/dev/null || echo "unknown")" != "offline" ]]; then
	if [[ -f "$UPD" ]] && [[ -s "$UPD" ]]; then
		awk '{ print $1 }' "$UPD" > "$UPO"
	fi
fi

echo "refreshing" > "$UPD" ; _sig

if ping -4 -n -c 1 -W 5 www.voidlinux.org >/dev/null 2>&1
then
	_sed_pc 100 0 ; _chck_upd | tee "$UPD" | wc -l > "$UPC"

	if [[ -s "$UPD" ]]
	then
		PKG=$(cat "$UPD" | xargs -n1 xbps-uhelper getpkgname 2>/dev/null || true)
		> "$UPI"  # Kosongkan file dulu
		for i in $(echo $PKG)
			do
				xbps-query -p pkgver "$i" 2>/dev/null |
					awk -F- '{ sub("", $NF); print "ï…· "$NF"" }' >> "$UPI" || true
			done
	else
		> "$UPI"
	fi

	if [[ -f "$UPO" ]] && diff "$UPD" "$UPO" >/dev/null 2>&1
	then
		[[ -s "$UPD" ]] || > "$UPN"

		_sed_cl updates ; _sed_nw ; _mkp
	else
		if [[ -f "$UPO" ]]; then
			comm -23 "$UPD" "$UPO" 2>/dev/null > "$UPN" || > "$UPN"
		else
			cp "$UPD" "$UPN" 2>/dev/null || > "$UPN"
		fi

		_sed_cl new-updates ; _sed_nw ; _mkp ; _sig

		sleep 10 && _sed_cl updates
	fi

	_sig
else
	if [[ -s "$UPO" ]]
	then
		_sed_pc 70 70 ; > "$UPD" ; _sig
	else
		_sed_pc 30 30 ; > "$UPD" ; _sig
	fi
fi

# Source code: "https://codeberg.org/dogknowsnx/dotfiles/scripts"
