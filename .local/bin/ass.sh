#!/bin/sh
# check vids folder, grab appropriate asses and hard/symlink
subsFolder=$1
numPlacement=$2
shift 2
for vid in "$@"; do
	num=$(basename "$vid" | awk "{print \$$numPlacement}")
	echo $num
	echo $vid
	ls "$subsFolder" | grep "$num " | while read sub; do
		ln -fs "$subsFolder/$sub" "$(echo "$vid" | sed 's/\(.*\)\..*/\1/').$(echo "$sub" | sed 's/.*\.//')"
	done
done

