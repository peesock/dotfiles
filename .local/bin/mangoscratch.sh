#!/bin/sh

# usage: mangoscratch.sh [options] key [command]
# todo:
# more states than float and fullscreen

[ "$MANGO_INSTANCE_SIGNATURE" ] || {
	echo no mango socket environment variable
	exit 1
}

programName=${0##*/}
stateFile=/tmp/$programName.state

get(){
	term=$1
	key=$2 # number
	val=$3 # number
	(printf '%s\0\n' "$term"; cat "$stateFile") | awk 'BEGIN{RS="\0\n"; FS="\0"; ORS=""}{
		if (NR==1) term=$0; else {
			if ($'"$key"' == term) {
				print $'"$val"'
				exit
			}
		}
	}'
}

remove(){
	tmp=$(mktemp)
	term=$1
	(printf '%s\0\n' "$term"; cat "$stateFile") | awk 'BEGIN{RS="\0\n"; FS="\0"; ORS="\0\n"}{
		if (NR==1) term=$0; else {
			if ($1 != term) {
				print $0
			}
		}
	}' > "$tmp"
	mv "$tmp" "$stateFile"
}

daemon(){
	mangopid=$(echo "${MANGO_INSTANCE_SIGNATURE##*/}" | tr -cd 0-9)
	printf '%s\0\0%s\0\n' daemonpid $$ >"$stateFile"
	trap 'kill $!; continue' USR1
	trap 'rm "$stateFile"' EXIT
	trap exit INT TERM HUP
	# basically store pid in statefile per command, signal daemon with usr1 to waitpid additional
	# things. to keep process count low, use 1 waitpid command, have it exit if any pids exit, and on
	# exit, inspect pid list to see what died. slight race condition risk but it will be fine. remove
	# the dead pid from statefile. also store mango pid to see if that died, in which case just remove
	# statefile.
	waitpid 1 &
	wait # wait for first signal :)
	while true; do
		pids=$(<"$stateFile" awk 'BEGIN{RS="\0\n"; FS="\0"; ORS=""}{ if (NR>=2) print $3 " "}')
		[ "$(echo $pids)" ] || exit
		waitpid -c 1 $mangopid $pids &
		wait
		[ -e /proc/$mangopid ] || exit
		for pid in $pids; do
			[ -e /proc/$pid ] || {
				key=$(get $pid 3 1)
				remove "$key"
			}
		done
	done
}

scale=0.5
while true; do
	case $1 in
		-daemon) daemon; exit;;
		-wh) wh=$2; shift 2;;
		-s) scale=$2; shift 2;;
		-f) fullscreen=1; shift;;
		-k) keep=1; shift;;
		-g) global=1; shift;;
		--) shift; break;;
		*) break;;
	esac
done
idKey=$1
shift

daemonPid=$(get daemonpid 1 3)
[ "$daemonPid" ] || "$0" -daemon &

present(){
	id=$1
	client=$(mmsg get client "$id")
	# [ false = "$(echo "$client" | jq -r '.is_global')" ] && mmsg dispatch toggleglobal "client,$id" >/dev/null

	if [ "$fullscreen" ]; then
		[ false = "$(echo "$client" | jq -r '.is_maximized')" ] && mmsg dispatch togglemaximizescreen "client,$id" >/dev/null
		[ false = "$(echo "$client" | jq -r '.is_fullscreen')" ] && mmsg dispatch togglefullscreen "client,$id" >/dev/null
		[ false = "$(echo "$client" | jq -r '.is_fakefullscreen')" ] && mmsg dispatch togglefakefullscreen "client,$id" >/dev/null
	else
		[ false = "$(echo "$client" | jq -r '.is_floating')" ] && mmsg dispatch togglefloating "client,$id" >/dev/null
		[ "$wh" ] || wh=$(echo "$WH" | awk 'BEGIN{FS=","}{print int($1 * '"$scale"') "," int($2 * '"$scale"')}')
		# xy=$(printf %s\\n%s "$WH" "$wh" |
		# 	awk 'BEGIN{FS=","}{
		# 		if (NR==1) {W=$1; H=$2}
		# 		else
		# 			print int(W - $1) / 2 "," int(H - $2) / 2
		# 		}'
		# 	)
			# mmsg dispatch "movewin,$xy" "client,$id" >/dev/null
			mmsg dispatch "resizewin,$wh" "client,$id" >/dev/null
			mmsg dispatch centerwin "client,$id" >/dev/null
	fi
}

getid(){
	fifo1=$(mktemp -u)
	fifo2=$(mktemp -u)
	mkfifo "$fifo1" "$fifo2"
	trap '[ "$fifo1" ] && rm "$fifo1" "$fifo2"' EXIT
	trap exit INT TERM HUP
	mmsg watch all-clients >"$fifo1" & pids=$!
	<"$fifo1" jq --unbuffered -c -r '.clients | map(select(.tags | any(. == '"$tag"'))) | map(.id)' |
		stdbuf -oL awk 'BEGIN{FS=","} {
			gsub(/\[|\]/, "");
			if (NR == 1) {split($0, arr, ","); print "ready"} else {
				for (i=1; i<=NF; i++) {
					b=1;
					for (j in arr) if (arr[j] == $i) {b=0; break}
					if (b==1) {print $i; exit}
				}
			}
		}' >"$fifo2" &
	read _ <"$fifo2"
	(sleep 10; echo timeout fail; kill 0) & pids="$pids $!"
	"$@" & cmdpid=$!
	(trap 'kill $!; exit' TERM; waitpid $! & wait; echo command fail; kill 0) & pids="$pids $!"
	read -r id <"$fifo2"
	kill $pids
	rm "$fifo1" "$fifo2"
	unset fifo1

	printf '%s\0%s\0%s\0\n' "$idKey" "$id" "$cmdpid" >>"$stateFile"
	echo kill -s USR1 "$daemonPid"
	kill -s USR1 "$daemonPid"
}

getinfo(){
	monitor=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active == true)')
	tag=$(echo "$monitor" | jq -r '.active_tags[0]')
	WH=$(echo "$monitor" | jq -r '"\(.width),\(.height)"')
}

begin(){
	[ "$#" -gt 0 ] || exit
	getinfo

	getid "$@"

	present "$id"
}

id=$(get "$idKey" 1 2; echo x)
id=${id%x}
if [ "$id" ]; then
	isVisible=$(mmsg get client "$id" | jq -r '.is_visible')
	if [ "$isVisible" = false ]; then
		getinfo
		mmsg dispatch "tag,$tag" "client,$id" >/dev/null
		# [ "$global" ] && mmsg dispatch toggleglobal "client,$id" >/dev/null
		[ "$global" ] && mmsg dispatch toggletag,0 "client,$id" >/dev/null
		[ "$keep" ] && {
			present "$id"
		}
	elif [ "$isVisible" = true ]; then
		mmsg dispatch tagsilent,0 "client,$id"
	else
		remove "$idKey"
		begin "$@"
		exit
	fi
else
	begin "$@"
fi
