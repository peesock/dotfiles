(
	{
		netwait.sh # wait for slow bitchass networkmanager (i use runit btw)

		mpd
		mpc pause

		transmission-daemon -g ~/.config/transmission
	} > /dev/null 2>&1 &
)
