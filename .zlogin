(
	{
		i=$(who | grep -F "$USER" | wc -l)
		# first tty login
		if [ $i -eq 1 ] && who | grep "^$USER\s*tty" >/dev/null; then
			echo hi
			for serv in "$HOME/.local/var/run/runit"/*; do
				# echo $serv
				runsv "$serv" &
			done
			while true; do echo "$(date)"; sleep 600; done &
		fi
	} & #>/dev/null 2>&1 &
)
# vim: ft=sh
