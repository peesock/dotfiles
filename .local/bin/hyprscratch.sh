#!/bin/sh
# i have become aware of a hyprland plugin that already does this BUT ITS PYTHON

# requires netcat
[ $# -lt 1 ] && exit
while true; do
	case "$1" in
		-nopersist)
			nopersist=true
			shift
			continue;;
		-float)
			float=true
			shift
			continue;;
		-center)
			center=true
			shift
			continue;;
		-resize)
			resize=$2
			shift 2
			continue;;
		--)
			shift
			break;;
	esac
	break
done
id=$1
[ $# -eq 1 ] && program=$id || program=$2

programName=$(basename "$0")
path=/tmp/$USER/$programName
mkdir -p "$path"

begin(){
	tmp=$(mktemp -u)
	mkfifo "$tmp"
	nc -U "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
		[ "${line%>>*}" = "openwindow" ] && {
			line=${line#*>>}
			echo "${line%,*,*,*}"
			break
		}
	done > "$tmp" & socket=$!
	sh -c "$program" & pid=$!
	(waitpid $pid; kill $socket; echo > "$tmp") &
	wid=0x$(cat "$tmp")
	rm "$tmp"
	[ "$wid" = "0x" ] && exit 1
	printf '%s\n' "$wid" "$pid" > "$path/$id"
	(kill $!; waitpid $pid; rm "$path/$id") &
	compute
	[ "$batch1" ] || [ "$batch2" ] && hyprctl --batch "$batch1 $batch2"
	exit
}

compute(){
	echo2(){
		printf '%s ' "$@"
	}
	batch1=$(
		[ "$float" ] && echo2 "dispatch setfloating address:$wid ;"
		[ "$resize" ] && echo2 "dispatch resizewindowpixel $resize,address:$wid ;"
	)
	batch2=$(
		[ "$center" ] && echo2 "dispatch centerwindow ;"
	)
}

# check if data file and then window exists
[ -f "$path/$id" ] || begin
wid=$(sed -n 1p "$path/$id")
data=$(hyprctl -j clients)
echo "$data" | grep -qF '"address": "'"$wid"'"' || begin
if [ "$(echo "$data" | jq '.[] | select(.address=="'"$wid"'") | .workspace.name | test("special")')" = 'true' ]; then
	[ "$nopersist" ] || compute
	hyprctl dispatch movetoworkspace +0,address:"$wid"
	[ "$batch2" ] && hyprctl --batch "$batch2"
else
	hyprctl dispatch movetoworkspacesilent special,address:"$wid"
	[ "$batch1" ] && hyprctl --batch "$batch1"
fi >/dev/null
