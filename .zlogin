(
	{
		i=$(who | awk '{if ($1 == "'$USER'") print}' | wc -l)
		# first tty login
		if [ $i -eq 1 ]; then
			echo hi
			for serv in "$HOME/.local/var/run/runit"/*; do
				# echo $serv
				runsv "$serv" &
			done
			while true; do echo "$(date)"; sleep 10m; done &
		fi
	} & #>/dev/null 2>&1 &
)
# vim: ft=sh
