(
	{
		i=$(who -q | sed -n 1p | grep -oh "$USER" | wc -l)
		# first login
		if [ $i -eq 1 ]; then
			echo hi
			pgrep -fx "runsvdir $HOME/.local/var/run/" >/dev/null ||
				runsvdir "$HOME/.local/var/run/"
		fi
	} & #>/dev/null 2>&1 &
)
