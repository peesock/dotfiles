i=$(who | grep -F "$USER" | wc -l)
# last tty logout but not really due to ssh issue that i am not addressing
if [ $i -eq 1 ] && who | grep "^$USER\s*tty" >/dev/null; then
	mpc pause >/dev/null 2>&1
	[ -d "$(readlink "$HOME/.mozilla/firefox")" ] &&
		browser-sync firefox ~/.mozilla/firefox

	# pkill -u "$USER"
fi
