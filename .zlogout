#!/bin/zsh
set +m

checkParents(){
	[ $# -lt 2 ] && echo 'checkArgs' && return 1
	pid=$1
	shift
	while true; do
		pid=$(cut -d' ' -f4 < "/proc/$pid/stat")
		[ "$pid" -le 1 ] && return 1
		for parent; do
			[ "$pid" -eq "$parent" ] && return 0
		done
	done
}

getParents(){
	who -u | awk '{if ($1 == "'$USER'") print $6}'
}

i=$(w -h "$USER" | wc -l)
if [ $i -le 1 ] && checkParents $$ $(getParents); then
	killer nofork
fi
# vim: ft=sh
