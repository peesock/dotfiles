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
	[ "$echo" ] && echo "$winid"
}

execute(){
	sh -c "exec $exe" >/dev/null & pid=$!

	# xdotool search --sync --pid "$pid" >/dev/null; sleep 0.2 #workaround a funny segfault
	winid="$(xdotool search --sync --pid "$pid")"
	# xprop -f "_$programName" 8s -set "_$programName" "$id" -id $winid
	printf "%s\n" "$winid" "$pid" > "$path/$id"
	echo_winid
	(waitpid $pid; rm "$path/$id") >/dev/null &
}

[ -f "$path/$id" ] && {
	winid=$(sed -n 1p "$path/$id")
	state=$(xwininfo -id "$winid" | grep -F "Map State" | awk '{print $3}')
}
if [ "$state" ]; then
	# xprop -id "$winid" 2>/dev/null | grep "^_$programName.*$id" >/dev/null || execute "$@"
	if [ "$state" = IsViewable ]; then
		xdotool windowunmap --sync "$winid"
	else
		xdotool windowmap "$winid"
		echo_winid
	fi
else
	execute
	exit
fi
