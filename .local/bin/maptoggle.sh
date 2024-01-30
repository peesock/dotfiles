#!/bin/sh
# note: allow tagging existing windows
# noter: the stupid X atom tagging method is unnecessary

uid="$(echo "$1" | tr -d ',')"
exe="$2"

scriptname="$(basename "$0")"
path="/tmp/$USER/$scriptname/"
mkdir -p "$path"

usage(){
	printf "\nUsage:\n"
	echo "\$1 - ID"
	echo "\$2 - Program"
	echo "-echo - Return window ID on visible"
	exit "${1-0}"
}

echo_winid(){
	[ $echo ] && echo "$winid"
}

execute(){
	[ $# -lt 2 ] && usage 1
	sed -i.bak "/^$uid,/d" "$path/processes"

	# instead of `commadn $exe & pid=$!`, fork the process to ensure the script
	# exits, and use a file to grab stdout independently of its process.
	tmp=$(mktemp)
	setsid -f sh -c "command $exe & echo \$!" > "$tmp"
	pid=$(cat "$tmp")
	rm "$tmp"

	state=1
	xdotool search --sync --pid "$pid" >/dev/null; sleep 0.2 #workaround a funny segfault
	winid="$(xdotool search --sync --pid "$pid")"
	xprop -f "_$scriptname" 8s -set "_$scriptname" "$uid" -id $winid
	echo "$uid,$winid,$state" >> "$path/processes"
	echo_winid
	exit
}

i=1
while [ $i -le $# ]; do
	eval "arg=\$$i"
	case $arg in
		"-echo")
			echo=true
			;;
	esac
	i=$((i + 1))
done

if line=$(grep -Fm 1 "$uid," "$path/processes"); then
	winid=$(echo "$line" | cut -d',' -f2)
	xprop -id "$winid" 2>/dev/null | grep "^_$scriptname.*$uid" >/dev/null || execute "$@"
	state=$(echo "$line" | cut -d',' -f3)
	if [ $state -eq 0 ]; then
		xdotool windowmap "$winid"
		sed -i.bak "/^$uid,/c\\$uid,$winid,1" "$path/processes"
		echo_winid
	else
		xdotool windowunmap --sync "$winid"
		sed -i.bak "/^$uid,/c\\$uid,$winid,0" "$path/processes"
	fi
else
	execute "$@"
fi
