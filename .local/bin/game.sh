#!/bin/sh
set -x
if [ "$1" != 1 ]; then
	args=$(mktemp)
	mountlist=$(mktemp)
	trap 'rm "$args" "$mountlist" 2>/dev/null' EXIT
	while true; do
		case $1 in
			-dir)
				if [ -f "$2" ]; then
					if [ "${2%.dwarfs}" != "$2" ]; then
						dir=${2%.*}
						mkdir -p "$dir"
						mountpoint -q -- "$dir" || dwarfs "$2" "$dir"
						printf %s\\0 "$dir" >>"$mountlist"
					else
						exit
					fi
				else
					dir=$2
				fi
				shift 2
				;;
			-p)
				export STEAM_COMPAT_DATA_PATH="$HOME/.local/share/proton-pfx/0"
				proton wineboot &
				printf %s\\0 -r "$STEAM_COMPAT_DATA_PATH" >>"$args"
				pids="$pids $!"
				shift
				;;
			-w)
				export WINEPREFIX="$HOME/.wine"
				wineboot &
				printf %s\\0 -r "$WINEPREFIX" >>"$args"
				pids="$pids $!"
				shift
				;;
			*)
				break
				;;
		esac
	done
	dir=${dir:-.}

	(cat "$args"; printf %s\\0 "$0" 1 "$dir" "$pids" "$@") | xargs -0 overlay2.sh -R -d -s storage

	n=$(tr -cd '\0' <"$mountlist" | wc -c) 2>/dev/null
	for i in $(seq 1 "$n" | tac); do
		line=$(sed -zn "$i"p <"$mountlist"; echo x)
		umount "${line%x}"
	done

else
	shift
	cd "$1" || exit
	[ "$2" ] && waitpid $2
	shift 2
	exec timer ../runtime "$@"
fi
