#!/bin/sh
# requires bwrap.sh for sandboxing (if you a pussy) and https://github.com/adlerosn/cicpoffs
if [ "$1" = 'fix' ]; then
	tmp=$(mktemp)
	find . -maxdepth 2 -type f -name 'package.json' | while read -r file; do
		jq 'if .name == "" then .name = "game" else . end' "$file" > "$tmp"
		cat "$tmp" > "$file"
	done
	rm "$tmp"
else
	set -x
	tmp=$(mktemp -d)
	cicpoffs . "$tmp"
	(waitpid $$; fusermount -u "$tmp"; rmdir "$tmp") &
	if command -v bwrap.sh >/dev/null; then
		exec bwrap.sh -noshare -display -gpu -cpu -audio -dbus -theme -autobind --ro-bind /opt /opt nw "$tmp"
	else
		exec nw "$tmp"
	fi
fi
