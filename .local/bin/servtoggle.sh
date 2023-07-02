#!/bin/sh
# toggles all listed services with killall and exec
alias notify='notify-send -u normal -t 1000'
[ "$1" = "-q" ] && q=true && shift
i=1
for service in "$@"; do
	base="$(echo $service | cut -d ' ' -f 1)"
	if pgrep -x "$base"; then
		[ $q ] || notify -r $i "Killing $service ..." &
		killall -s 1 "$base" && ( [ $q ] || notify -r $i "Killed:" "$service" )
	else
		[ $q ] || notify -r $i "Starting $service" &
		exec $service &
	fi
	i=$(($i + 1))
done
