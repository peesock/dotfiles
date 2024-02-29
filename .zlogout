#!/bin/zsh
set +m

checkParents(){
	[ $# -lt 2 ] && echo 'checkArgs' && return 1
	pid=$1
	shift
	while true; do
		pid=$(sed -n 's/^PPid:\s\+//p' < "/proc/$pid/status")
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
echo i=$i >> ~/superlog
getParents >> ~/superlog
ps $(getParents) >> ~/superlog
if [ $i -le 1 ] && checkParents $$ $(getParents); then
	echo "i am KILLING things at $(date)" >> ~/superlog
	killer "$USER" noparent
fi
echo "i am ENDING my zlogout at $(date)" >> ~/superlog
# vim: ft=sh
