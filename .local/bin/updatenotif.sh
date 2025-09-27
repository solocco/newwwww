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

UPC=/tmp/upd/count
UPD=/tmp/upd/updates
UPI=/tmp/upd/installed
UPN=/tmp/upd/new
UPO=/tmp/upd/old
PRT=/tmp/upd/pretty
UBR=$HOME/.local/bin/updbar.py
SND=$HOME/.local/share/sounds

CFG=$HOME/.local/share/upd.conf
snd_cfg=$(jq -r .sound ${CFG})
cin_cfg=$(jq -r .check_interval ${CFG})
rtr_cfg=$(jq -r .retry_interval ${CFG})

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
	sed -i -e "10s/${PC}\ =\ [0-9\"]*/${PC}\ =\ $1/" \
		   -e "22s/${PC}\ =\ [0-9\"]*/${PC}\ =\ $2/" ${UBR}
}

_sed_cl() {
	sed -i "27s/clss =\ .*\ #/clss\ =\ \"$1\"\ #/" ${UBR}
}

_sed_nw() {
	local IFS=$'\n'
	for i in $(< ${UPN})
		do
			sed -i "s/$i.*/&\ \ \ NEW/" ${UPD}
		done

	sed -i "s/NEW.*/NEW\ \ /g" ${UPD}
}

_mkp() {
	paste -d' ' ${UPD} ${UPI} > ${PRT}
}

_sig() {
	pkill -x -SIGRTMIN+9 waybar
}

_apl() {
	if type aplay >/dev/null 2>&1
	then
		aplay -q --file-type=wav ${SND}/${snd_cfg} 2>/dev/null &
	else
		paplay ${SND}/${snd_cfg} 2>/dev/null &
	fi
}

mkdir /tmp/upd

: > ${UPI} ; : > ${UPN} ; : > ${UPO} ; echo 0 > ${UPC}

[[ -f ${UPD} ]] || _chck_upd > ${UPD} >/dev/null 2>&1

while [[ -f ${UPC} ]]
	do
		if [[ "$(python ${UBR} | jq -r .class)" != "offline" ]]
		then
			awk '{ print $1 }' ${UPD} > ${UPO}
		fi

		echo "refreshing" > ${UPD} ; _sig

		if ping -4 -n -c 1 -W 5 www.voidlinux.org >/dev/null 2>&1
		then
			_sed_pc 100 0 ; _chck_upd | tee ${UPD} | wc -l > ${UPC}

			if [[ -s ${UPD} ]]
			then
				PKG=$(cat ${UPD} | xargs -n1 xbps-uhelper getpkgname)
				for i in $(echo ${PKG})
					do
						xbps-query -p pkgver ${i} |
							awk -F- '{ sub("", $NF); print " "$NF"" }'
					done > ${UPI}
			else
				: > ${UPI}
			fi

			if diff ${UPD} ${UPO} >/dev/null 2>&1
			then
				[[ -s ${UPD} ]] || : > ${UPN}

				_sed_cl updates ; _sed_nw ; _mkp
			else
				comm -23 ${UPD} ${UPO} 2>/dev/null > ${UPN}

				_sed_cl new-updates ; _sed_nw ; _mkp ; _sig ; _apl

				sleep 10 && _sed_cl updates
			fi

			 _sig ; sleep ${cin_cfg}m
		else
			if [[ -s ${UPO} ]]
			then
				_sed_pc 70 70 ; : > ${UPD} ; _sig

				sleep ${rtr_cfg}m
			else
				_sed_pc 30 30 ; : > ${UPD} ; _sig

				sleep ${rtr_cfg}m
			fi
		fi
	done

# Source code: "https://codeberg.org/dogknowsnx/dotfiles/scripts"

