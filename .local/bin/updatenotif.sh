#!/usr/bin/env bash
#
#[v0.1.0]
#
# This script depends on 'jq' 'python' 'xbps'
#
#
#[ "${ULOCKER}" != "$0" ] &&
#	exec env ULOCKER="$0" flock -en "$0" "$0" "$@" || :

#PID=$HOME/.config/service/updatenotif/supervise/pid
#if [[ -s ${PID} ]]
#then
#	[[ "$(< ${PID})" != "$$" ]] && exit 1
#fi

# Pastikan direktori utama ada
UPD_DIR=/tmp/upd
mkdir -p "$UPD_DIR"

UPC="$UPD_DIR/count"
UPD="$UPD_DIR/updates"
UPI="$UPD_DIR/installed"
UPN="$UPD_DIR/new"
UPO="$UPD_DIR/old"
PRT="$UPD_DIR/pretty"
UBR=$HOME/.local/bin/updbar.py
SND=$HOME/.local/share/sounds

# Pastikan file konfigurasi ada
CFG=$HOME/.local/share/upd.conf
if [[ ! -f "$CFG" ]]; then
    # Buat konfigurasi default jika tidak ada
    mkdir -p "$(dirname "$CFG")"
    cat > "$CFG" << 'EOF'
{
  "sound": "notification.wav",
  "check_interval": 30,
  "retry_interval": 3
}
EOF
fi

# Baca konfigurasi dengan fallback ke default
snd_cfg=$(jq -r '.sound // "notification.wav"' "$CFG" 2>/dev/null || echo "notification.wav")
cin_cfg=$(jq -r '.check_interval // 30' "$CFG" 2>/dev/null || echo 30)
rtr_cfg=$(jq -r '.retry_interval // 3' "$CFG" 2>/dev/null || echo 3)

# Validasi konfigurasi
if [[ "${cin_cfg}" -lt 15 ]] || [[ "${cin_cfg}" -gt 99 ]]
then
	cin_cfg=30
fi

if [[ "${rtr_cfg}" -lt 1 ]] || [[ "${rtr_cfg}" -gt 99 ]]
then
	rtr_cfg=3
fi

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

_apl() {
	local sound_file="$SND/$snd_cfg"
	if [[ -f "$sound_file" ]]; then
		if type aplay >/dev/null 2>&1; then
			aplay -q --file-type=wav "$sound_file" 2>/dev/null &
		elif type paplay >/dev/null 2>&1; then
			paplay "$sound_file" 2>/dev/null &
		fi
	fi
}

# Inisialisasi file-file yang diperlukan
touch "$UPI" "$UPN" "$UPO" "$PRT"
echo 0 > "$UPC"

# Cek jika UPD belum ada atau kosong, lakukan pengecekan awal
if [[ ! -f "$UPD" ]] || [[ ! -s "$UPD" ]]; then
	_chck_upd > "$UPD" 2>/dev/null || touch "$UPD"
fi

while [[ -f "$UPC" ]]
	do
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

				_sed_cl new-updates ; _sed_nw ; _mkp ; _sig ; _apl

				sleep 10 && _sed_cl updates
			fi

			 _sig ; sleep ${cin_cfg}m
		else
			if [[ -s "$UPO" ]]
			then
				_sed_pc 70 70 ; > "$UPD" ; _sig

				sleep ${rtr_cfg}m
			else
				_sed_pc 30 30 ; > "$UPD" ; _sig

				sleep ${rtr_cfg}m
			fi
		fi
	done

# Source code: "https://codeberg.org/dogknowsnx/dotfiles/scripts"
