#!/bin/sh

# usage: mangoscratch.sh [options] key [command]
# todo:
# more states than float and fullscreen
# make present() clear other intruding states
# die and clear with processes

scale=0.5
while true; do
	case $1 in
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
programName=${0##*/}
stateFile=/tmp/$programName.state
touch "$stateFile"

get(){
	term=$1
	(printf '%s\0\n' "$term"; cat "$stateFile") | awk 'BEGIN{RS="\0\n"; FS="\0"; ORS=""}{
		if (NR==1) term=$0; else {
			if ($1 == term) {
				print $2
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
	"$@" &
	(waitpid $!; echo command fail; kill 0) & pids="$pids $!"
	read -r id <"$fifo"
	kill $pids
	rm "$fifo"
	unset fifo
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

	printf '%s\0%s\0\n' "$idKey" "$id" >>"$stateFile"
}

id=$(get "$idKey"; echo x)
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
