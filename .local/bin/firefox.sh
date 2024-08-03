#!/bin/sh
dir=$HOME/.mozilla/firefox

# memory-sync firefox "$dir" disk 2>/dev/null
# (sleep 1; exec memory-sync -D -e -u 30m -t 5 firefox "$dir" "firefox") &
realdir=$(realpath "$dir")
# exec bwrap.sh -preset browser --bind "$dir" "$dir" -- firefox-developer-edition
exec bwrap.sh -preset browser --bind ~ ~ --bind "$realdir" "$realdir" -- firefox-developer-edition "$@"
# exec firefox-developer-edition
