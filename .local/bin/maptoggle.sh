#!/bin/sh

id=$1
exe=${2-"$1"}

programName="$(basename "$0")"
path="/tmp/$USER/$programName"
mkdir -p "$path"

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

usage(){
	cat <<- EOF
	Usage:
	\$1 - ID
	\$2 - Program
	-echo - Return window ID on visible
	EOF
	exit "${1-0}"
}

echo_winid(){
	[ "$echo" ] && echo "$wid"
}

exec_winid(){
	# sets global vars $wid and $pid (and $tmp)
	tmp=$(mktemp)
	xwininfo -root -tree | grep '^\s*0x[0-9]\+' | grep -v '\s\+1x1+0+0\s\++0+0' | awk '{print $1}' | sort > "$tmp"
	"$@" & pid=$!
	(waitpid $pid; kill $$) &
	while true; do
		for wid in $(xwininfo -root -tree | grep '^\s*0x[0-9]\+' | grep -v '\s\+1x1+0+0\s\++0+0' | awk '{print $1}' | sort | comm --nocheck-order -13 "$tmp" -); do
			xwininfo -id "$wid" | grep -qF 'Map State: IsViewable' && break 2
		done
		sleep 0.05
	done
	kill $!
	rm "$tmp"
} >&2

execute(){
	exec_winid sh -c "exec $exe"
	# xprop -f "_$programName" 8s -set "_$programName" "$id" -id $winid
	printf "%s\n" "$wid" "$pid" > "$path/$id"
	echo_winid
	(waitpid $pid; rm "$path/$id") >/dev/null &
}

[ -f "$path/$id" ] && {
	wid=$(sed -n 1p "$path/$id")
	state=$(xwininfo -id "$wid" | grep -F "Map State" | awk '{print $3}')
}
if [ "$state" ]; then
	# xprop -id "$winid" 2>/dev/null | grep "^_$programName.*$id" >/dev/null || execute "$@"
	if [ "$state" = IsViewable ]; then
		xdotool windowunmap --sync "$wid"
	else
		xdotool windowmap "$wid"
		echo_winid
	fi
else
	execute
	exit
fi
