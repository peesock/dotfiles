#!/bin/sh
# check vids folder, grab appropriate asses and symlink
subsFolder=$1
numPlacement=$2
shift 2
export LC_ALL=C
for vid in "$@"; do
	num=$(basename "$vid" | awk "{print \$$numPlacement}")
	echo $num
	echo $vid
	find "$subsFolder" -maxdepth 1 -type f | grep -F "$num " | while read -r sub; do
		ln -fs "$sub" "$(echo "$vid" | sed 's/\(.*\)\..*/\1/').$(echo "$sub" | sed 's/.*\.//')"
	done
done

