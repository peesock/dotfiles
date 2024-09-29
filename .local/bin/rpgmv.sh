#!/bin/sh
# requires bwrap.sh for sandboxing (if you want), https://github.com/adlerosn/cicpoffs, and nwjs
set -x
if [ "$1" = 'fix' ]; then
	tmp=$(mktemp)
	find . -maxdepth 2 -type f -name 'package.json' | while read -r file; do
		jq 'if .name == "" then .name = "game" else . end' "$file" > "$tmp"
		cat "$tmp" > "$file"
	done
	rm "$tmp"
else
	if [ "$1" = "nomount" ]; then
		tmp=$(mktemp -u)
		exec bwrap.sh -noshare -display -gpu -cpu -audio -dbus -theme --bind "$PWD" "$tmp" --ro-bind /opt /opt nw "$tmp"
	else
		tmp=$(mktemp -d)
		cicpoffs . "$tmp"
		(waitpid $$; fusermount -z "$tmp"; rmdir "$tmp") &
		exec bwrap.sh -noshare -display -gpu -cpu -audio -dbus -theme -autobind --ro-bind /opt /opt nw "$tmp"
	fi
fi
