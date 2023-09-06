#!/bin/sh
# removes username with regex

# just replace every "$USER" with "user".
[ $1 = '-g' ] && greedy=true && shift
# bad idea on large files if your username is like 2 letters

input=$1 output=${2-"$(echo "$input" | sed 's/\(.*\)\(\..*\)\|\(.*\)/\1\3-dd\2/')"}

if [ $greedy ]; then
	sed "s/$USER/user/gI" "$input" > "$output"
else
	# one line baybie
	sed "s/\(\/\)$USER\|$USER\(\s\+\)\|\(\s\+\)$USER\|^$USER$/\1\3user\2/gI"
	"$input" > "$output"
fi
