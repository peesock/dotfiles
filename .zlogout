#!/bin/zsh
set +m
echo logging out $(date) >>~/gloggy
who -u >>~/gloggy

checkParents(){
	[ $# -lt 2 ] && echo 'checkArgs' && return 1
	pid=$1
	shift
	while true; do
		for parent; do
			[ "$pid" -eq "$parent" ] && return 0
		done
		pid=$(cut -d' ' -f4 < "/proc/$pid/stat")
		[ "$pid" -le 1 ] && return 1
	done
}

getParents(){
	who -u | awk '{if ($1 == "'"$USER"'") print $6}'
}

i=$(who -u | awk 'BEGIN{i=0}{if ($1 == "'"$USER"'") i++}END{print i}')
if [ $i -le 1 ] && checkParents $$ $(getParents); then
	echo killing $(date) >>~/gloggy
	killer nofork
fi
# vim: ft=sh
