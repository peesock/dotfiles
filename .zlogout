(
{
	# i want to use the login manager but not really
	who=$(who | awk '{if $1 == '"$USER"' print}' | wc -l)
	if [ "$who" -le 1 ]; then
		i=0
		until [ -z "$who" ]; do
			who=$(who | awk '{if $1 == '"$USER"' print}')
			[ $i -ge 10 ] && exit 1
			sleep 0.2
			i=$((i + 1))
		done
		# put down all services on last logout
		for s in "$HOME/.local/var/run/runit"/*; do svu x "$s" & done
	fi
} &
)
# vim: ft=sh
