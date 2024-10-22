#!/bin/sh
set -x
tmp="$(mktemp tmp.XXXX.png)"
cover=$tmp
input=$(realpath "$1")
if ! ffmpeg -i "$input" "$tmp" -y; then
	rm "$tmp"
	unset tmp
	cover=$(find "${input%/*}" -maxdepth 2 -type f -print0 | xargs -0 file -00 --mime-type -- 2>/dev/null | awk 'BEGIN{RS="\0"} {if((NR % 2) == 0) {if($NF ~ /image\//){ORS="\0"; print var; exit}} else var = $0}')
	cover=${cover:-$HOME/download/assets/speaker-orange.png}
fi

nice ffmpeg -loop 1 -i "${cover}" -i "$input" -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -r 5 -pix_fmt yuv420p -tune stillimage -crf 30 -c:a aac -b:a 530k -ar 48000 -shortest "${2:-$(printf %s "$input" | sed 's/\(.*\)\..*/\1/')}".mp4
[ "$tmp" ] && rm "$tmp"
notify-send -t 3000 "Done converting"
