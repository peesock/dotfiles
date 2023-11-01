i=$(who -q | sed -n 1p | grep -oh "$USER" | wc -l)
# last logout
if [ $i -eq 1 ]; then
	mpc pause >/dev/null 2>&1
	[ -d "$(readlink "$HOME/.mozilla/firefox")" ] &&
		browser-sync firefox ~/.mozilla/firefox

	pkill -u "$USER"
fi
