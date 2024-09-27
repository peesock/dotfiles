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
	# tmp=.
	# [ "$1" = "nomount" ] || {
	# 	tmp=$(mktemp -d)
	# 	cicpoffs . "$tmp"
	# 	(waitpid $$; fusermount -u "$tmp"; rmdir "$tmp") &
	# }
	# if command -v bwrap.sh >/dev/null; then
	# 	exec bwrap.sh -noshare -display -gpu -cpu -audio -dbus -theme -autobind --ro-bind /opt /opt nw "$tmp"
	# else
	# 	exec nw "$tmp"
	# fi
	if command -v bwrap.sh >/dev/null; then
		tmp=$(mktemp -up /)
		exec bwrap.sh -noshare -display -gpu -cpu -audio -dbus -theme --ro-bind /opt /opt --bind "$PWD" "$tmp" nw "$tmp"
	else
		exec nw "$tmp"
	fi
	
fi
