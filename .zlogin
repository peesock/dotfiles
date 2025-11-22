[ "$DBUS_SESSION_BUS_ADDRESS" ] ||
	exec dbus-run-session -- zsh -l
(
	{
		# first login
		if [ ! -e "$XDG_RUNTIME_DIR/.login" ]; then
			touch "$XDG_RUNTIME_DIR/.login"
			echo first login!
			(
				if inotifywait -e unmount -e delete_self -- "$XDG_RUNTIME_DIR/.login"; then
					for s in "$HOME/.local/var/run/runit"/*; do svu x "$s" & done
				else
					echo "inotify logout fail!"
				fi
			) &
			basename -za "$HOME/.local/var/run/runit"/* | xargs -0 svurun
		fi
	} &
)
# vim: ft=sh
