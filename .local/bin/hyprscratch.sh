#!/bin/sh -x
# i have become aware of a hyprland plugin that already does this BUT ITS PYTHON

# requires netcat
[ $# -lt 1 ] && exit
while true; do
	case "$1" in
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
program=${2-"$1"}

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
	hyprctl --batch "dispatch focuswindow address:$wid ; $batch1 $batch2"
	exit
}

compute(){
	batch1="dispatch focuswindow address:$wid ; dispatch alterzorder top,address:$wid ;"
	[ "$float" ] && batch1="$batch1 dispatch setfloating address:$wid ;"
	[ "$resize" ] && batch1="$batch1 dispatch resizewindowpixel $resize,address:$wid ;"

	[ "$center" ] && batch2="$batch2 dispatch centerwindow ;"
}

# check if data file and then window exists
[ -f "$path/$id" ] || begin
wid=$(sed -n 1p "$path/$id")
data=$(hyprctl -j clients)
echo "$data" | grep -qF '"address": "'"$wid"'"' || begin
if [ "$(echo "$data" | jq '.[] | select(.address=="'"$wid"'") | .workspace.name | test("special")')" = 'true' ]; then
	compute
	hyprctl --batch "$batch1 dispatch movetoworkspace +0,address:$wid ; $batch2"
else
	hyprctl --batch "dispatch movetoworkspacesilent special,address:$wid"
fi >/dev/null
