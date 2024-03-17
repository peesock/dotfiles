(
	{
		i=$(who | awk '{if ($1 == "'$USER'") print}' | wc -l)
		# first tty login
		if [ $i -eq 1 ]; then
			echo hi
			svurun "$HOME/.local/var/run/runit"/*
		fi
	} &
)
# vim: ft=sh
