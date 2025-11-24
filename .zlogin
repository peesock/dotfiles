# first login
if [ ! -e "$XDG_RUNTIME_DIR/.login" ]; then
	echo first login!
	touch "$XDG_RUNTIME_DIR/.login"
	setsid -f dinit -q -u >/dev/null 2>&1 0>&1
fi

# vim: ft=sh
