#!/bin/sh
set -x
tmp="$(mktemp tmp.XXXXXXX.png)"
cover=$tmp
input=$(realpath "$1")
ffmpeg -i "$input" "$tmp" -y
if [ $# -ge 2 ] || ! file --mime-type | cut -d: -f2- | grep -q image/; then
	cover=$(
		dir="${2:-"${input%/*}"}"
		tmp2=$(mktemp)
		# breadth-first search for files
		find "$dir" -maxdepth 1 -type d -print0 > "$tmp2"
		n=1
		m=$(tr -cd \\0 < "$tmp2" | wc -c)
		while [ "$n" -le "$m" ]; do
			dir=$(head -zn$n < "$tmp2"; echo x)
			dir=${dir%x}
			n=$((n + 1))
			for file in "$dir"/*; do
				[ -d "$file" ] || printf %s\\0 "$file"
			done
		done |
			xargs -0 file -00 --mime-type -- 2>/dev/null |
			awk 'BEGIN{RS="\0"} {if((NR % 2) == 0) {if($NF ~ /image\//){ORS="\0"; print var; exit}} else var = $0}'
		echo x
		rm "$tmp2"
	)
	cover=${cover%x}
	if [ -z "$cover" ]; then
		cover=$HOME/download/assets/speaker-orange.png
	else
		magick -- "$cover" -resize '2000>' "$tmp"
		cover=$tmp
	fi
else
	magick -- "$tmp" -resize '2000>' "$tmp"
fi

nice ffmpeg -loop 1 -i "${cover}" -i "$input" -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -r 5 -pix_fmt yuv420p -tune stillimage -crf 30 -c:a aac -b:a 530k -ar 44100 -shortest "$(printf %s "$input" | sed 's/\(.*\)\..*/\1/').mp4"
rm "$tmp"
notify-send -t 3000 "Done converting" &
