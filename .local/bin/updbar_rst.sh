#!/usr/bin/env bash

UPC=/tmp/upd/count
UPI=/tmp/upd/installed
UPD=/tmp/upd/updates
UPN=/tmp/upd/new
UPO=/tmp/upd/old
PRT=/tmp/upd/pretty
UBR=$HOME/.local/bin/updbar.py

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

		_sed_cl new-updates ; _sed_nw ; _mkp ; _sig

		sleep 10 && _sed_cl updates
	fi

	_sig
else
	if [[ -s ${UPO} ]]
	then
		_sed_pc 70 70 ; : > ${UPD} ; _sig
	else
		_sed_pc 30 30 ; : > ${UPD} ; _sig
	fi
fi

# Source code: "https://codeberg.org/dogknowsnx/dotfiles/scripts"
