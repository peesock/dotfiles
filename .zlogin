(
	{
		i=$(who | awk '{if ($1 == "'$USER'") print}' | wc -l)
		# first tty login
		if [ $i -eq 1 ]; then
			echo hi
			basename -za "$HOME/.local/var/run/runit"/* | xargs -0 svurun
		fi
	} &
)
# vim: ft=sh
