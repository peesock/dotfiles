#!/bin/sh

dir=~/.mozilla/firefox/
checksync(){
	echo checking sync
	[ "$1" ] && {
		sleep "$1" & # must be >1
	}
	lastChar=$(svu check firefox-ram | LC_ALL=C grep -o '^ok: run: .\+) [0-9]' | tail -c2) && [ "$lastChar" -gt 0 ] 2>/dev/null || {
		[ -d /proc/$! ] || return 1
		sleep 0.1
		checksync
	}
	return 0
}

memory-sync firefox "$dir" 2>/dev/null & pid=$!
svu check firefox-ram >/dev/null && {
	if svu check firefox-ram | LC_ALL=C grep '^ok: run: ' >/dev/null; then
		exec firefox-developer-edition
	else
	svu u firefox-ram
	checksync 5 && {
		wait $pid
		exec firefox-developer-edition
	}
	fi
}
echo 'service not working, using local daemon'
trap 'kill $!' INT TERM
wait $pid
firefox-developer-edition &
memory-sync -D -e -u 30m -t 5 firefox "$dir" "firefox"
wait $!
