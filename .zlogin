(
	{
		# wait for slow bitchass networkmanager (i use runit btw)
		netwait.sh

		# start mpd
		mpd
		mpc pause

		# start torrent daemon
		transmission-daemon

	} >/dev/null 2>&1 &
)
