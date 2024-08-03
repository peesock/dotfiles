[ "$DBUS_SESSION_BUS_ADDRESS" ] ||
	exec dbus-run-session -- zsh -l
(
	{
		i=$(who | awk 'BEGIN{i=0} {if ($1 == "'"$USER"'") i++} END{print i}')
		# first tty login
		if [ $i -eq 1 ]; then
			echo hi
			(pipewire & pipewire-pulse & sleep 1; wireplumber &) &
			basename -za "$HOME/.local/var/run/runit"/* | xargs -0 svurun
		fi
	} &
)
# vim: ft=sh
