#!/bin/sh

# requires netcat
[ $# -lt 1 ] && exit
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
	[ "$wid" = "0x" ] && exit
	printf '%s\n' "$wid" "$pid" > "$path/$id"
	(kill $!; waitpid $pid; rm "$path/$id") &
	exit
}

# check if data file and then window exists
[ -f "$path/$id" ] || begin
wid=$(sed -n 1p "$path/$id")
data=$(hyprctl -j clients)
echo "$data" | grep -qF '"address": "'"$wid"'"' || begin
echo "$wid"
if [ "$(echo "$data" | jq '.[] | select(.address=="'"$wid"'") | .workspace.name | test("special")')" = 'true' ]; then
	hyprctl dispatch movetoworkspacesilent +0,address:"$wid"
else
	hyprctl dispatch movetoworkspacesilent special,address:"$wid"
fi >/dev/null
