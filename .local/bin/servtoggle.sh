#!/bin/sh
# toggles all listed services with killall and exec
alias notify='notify-send -u normal -t 1000'
eval 'set -- '$(getopt -o 'qp' -- "$@")
while true; do
	[ "$1" = "-q" ] && q=true && shift
	[ "$1" = "-p" ] && pause=true && shift
	[ "$1" = "--" ] && shift && break
done
i=1
if ! [ $pause ]; then
	for service in "$@"; do
		base="$(echo "$service" | cut -d ' ' -f 1)"
		if pgrep -x "$base"; then
			[ $q ] || notify -r $i "Killing $service ..." &
			killall -s 1 "$base" && ( [ $q ] || notify -r $i "Killed:" "$service" )
		else
			[ $q ] || notify -r $i "Starting $service" &
			exec $service &
		fi
		i=$(($i + 1))
	done
else
	for service in "$@"; do
		base="$(echo "$service" | cut -d ' ' -f 1)"
		if ps -o stat= $(pgrep -xn "$base") | grep '^T' >/dev/null; then
			[ $q ] || notify -r $i "Resuming $service ..." &
			killall -s CONT "$base" && ( [ $q ] || notify -r $i "Resumed:" "$service" )
		else
			[ $q ] || notify -r $i "Pausing $service" &
			killall -s STOP "$base" && ( [ $q ] || notify -r $i "Paused:" "$service" )
		fi
		i=$(($i + 1))
	done
fi
