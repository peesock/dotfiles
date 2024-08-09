[ "$DBUS_SESSION_BUS_ADDRESS" ] ||
	exec dbus-run-session -- zsh -l
(
	{
		# first login
		if [ ! -e $XDG_RUNTIME_DIR/.login ]; then
			touch $XDG_RUNTIME_DIR/.login
			echo hi
			basename -za "$HOME/.local/var/run/runit"/* | xargs -0 svurun
		fi
	} &
)
# vim: ft=sh
