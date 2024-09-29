#!/bin/sh
tmp="$(mktemp tmp.XXXX.png)"
cover=$tmp
if ! ffmpeg -i "$1" "$tmp" -y; then
	rm "$tmp"
	unset tmp
	cover=$(find "${1%/*}" -exec file --mime-type {} \+ | sed -n '/^.*:\s\+image/p' | head -n1 | sed 's/^\(.*\):.*/\1/')
	cover=${cover-$HOME/download/assets/speaker-orange.png}
fi

ffmpeg -loop 1 -i "${cover}" -i "$1" -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -r 5 -pix_fmt yuv420p -tune stillimage -crf 30 -c:a aac -b:a 530k -ar 48000 -shortest "${2:-$(printf %s "$1" | sed 's/\(.*\)\..*/\1/')}".mp4
[ "$tmp" ] && rm "$tmp"
notify-send -t 3000 "Done converting"
