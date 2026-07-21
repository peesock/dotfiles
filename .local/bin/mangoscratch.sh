#!/bin/sh

# usage: mangoscratch.sh [options] key [command]
# todo:
# more states than float and fullscreen
# make present() clear other intruding states

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
		--) shift; break;;
		*) break;;
	esac
done
idKey=$1
shift

daemonPid=$(get daemonpid 1 3)
[ "$daemonPid" ] || {
	mangopid=$(echo "${MANGO_INSTANCE_SIGNATURE##*/}" | tr -cd 0-9)
	"$0" -daemon & daemonPid=$!
	printf '%s\0\0%s\0\n' daemonpid $daemonPid >"$stateFile"
}

present(){
	id=$1
	client=$(mmsg get client "$id")
	if [ "$fullscreen" ]; then
		[ false = "$(echo "$client" | jq -r '.is_fullscreen')" ] && mmsg dispatch togglefullscreen "client,$id" >/dev/null
	else
		[ false = "$(echo "$client" | jq -r '.is_floating')" ] && mmsg dispatch togglefloating "client,$id" >/dev/null
		WH=$(mmsg get monitor "$monitor" | jq -r '"\(.width),\(.height)"')
		[ "$wh" ] || wh=$(echo "$WH" | awk 'BEGIN{FS=","}{print int($1 * '"$scale"') "," int($2 * '"$scale"')}')
		xy=$(printf %s\\n%s "$WH" "$wh" |
			awk 'BEGIN{FS=","}{
				if (NR==1) {W=$1; H=$2}
				else
					print int(W - $1) / 2 "," int(H - $2) / 2
				}'
			)
			mmsg dispatch "movewin,$xy" "client,$id" >/dev/null
			mmsg dispatch "resizewin,$wh" "client,$id" >/dev/null
	fi
}

getid(){
	fifo=$(mktemp -u)
	mkfifo "$fifo"
	trap '[ "$fifo" ] && rm "$fifo"' EXIT
	trap exit INT TERM HUP
	mmsg watch all-clients | jq --unbuffered -c -r \
		'.clients | map(select(.tags | any(. == '"$tag"'))) | map(.id)' | stdbuf -oL awk \
		'BEGIN{FS=","} {
			gsub(/\[|\]/, "");
			if (NR == 1) {split($0, arr, ","); print "ready"} else {
				for (i=1; i<=NF; i++) {
					b=1;
					for (j in arr) if (arr[j] == $i) {b=0; break}
					if (b==1) {print $i; exit}
				}
			}
		}' >"$fifo" &
	read _ <"$fifo"
	(sleep 10; echo timeout fail; kill 0) & pids=$!
	"$@" & cmdpid=$!
	(waitpid $!; echo command fail; kill 0) & pids="$pids $!"
	read -r id <"$fifo"
	kill $pids
	rm "$fifo"
	unset fifo

	printf '%s\0%s\0%s\0\n' "$idKey" "$id" "$cmdpid" >>"$stateFile"
	echo kill -s USR1 "$daemonPid"
	kill -s USR1 "$daemonPid"
}

getinfo(){
	monitor=$(mmsg get focusing-client | jq -r '.| "\(.monitor)\n\(.tags[0])"')
	tag=$(echo "$monitor" | tail -n1)
	monitor=$(echo "$monitor" | head -n1)
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
	minimized=$(mmsg get client "$id" | jq -r '.is_minimized')
	if [ "$minimized" = true ]; then
		mmsg dispatch focusid "client,$id" >/dev/null
		[ "$keep" ] && {
			getinfo
			present "$id"
		}
		# mmsg dispatch restore_minimized "client,$id" >/dev/null
	elif [ "$minimized" = false ]; then
		mmsg dispatch minimized "client,$id" >/dev/null
	else
		remove "$idKey"
		begin "$@"
		exit
	fi
else
	begin "$@"
fi
