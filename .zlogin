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
					echo last logout!
					dinitctl -u shutdown
				else
					echo "inotify logout fail!"
				fi
			) &
			exec dinit -u
		fi
	} &
)
# vim: ft=sh
