#!/bin/sh
# bwrap boilerplate. not meant to work everywhere, only work well enough to quickly sandbox my personal stuff.
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR-"/run/user/$(id -u)"}
WINEPREFIX=${WINEPREFIX-"$HOME/.wine"}

echo2(){
	var=$(printf '%s ' "$@")
	printf '%s\n' "${var%?}"
	var=
}

executer(){
	arg=$(eval "$2" | while read -r file; do
		printf '%s ' "'$1' '$file' '$file'"
	done)
	args="$args $arg"
}

while true; do
	case "$1" in
		-echo)
			echo=true
			shift
			continue;;
		-more)
			args="$args --unshare-all --share-net"
			shift
			continue;;
		-env)
			arg=$(for var in $2; do eval 'printf -- "--setenv %s %s\n" "$var" "$'"$var"'"' ; done)
			args="$args --clearenv $arg"
			shift 2
			continue;;
		-root)
			args="$args --unshare-user --uid 0 --gid 0 --setenv USER root --setenv HOME /root"
			shift
			continue;;
		-wine)
			args="$args --bind-try '$WINEPREFIX' '$WINEPREFIX'"
			shift
			continue;;
		-xorg)
			args="$args --ro-bind-try /tmp/.X11-unix /tmp/.X11-unix"
			shift
			continue;;
		-exec)
			executer "$2" "$3"
			shift 3
			continue;;
		-graphics)
			executer --dev-bind-try 'find /dev -maxdepth 1 -name nvidia\*; echo /dev/dri'
			shift
			continue;;
		-cpu)
			args="$args --dev-bind-try /sys/devices/system/cpu /sys/devices/system/cpu"
			shift
			continue;;
		-audio)
			executer --ro-bind 'find "$XDG_RUNTIME_DIR" -maxdepth 1 | grep "/pipewire\|/pulse"'
			shift
			continue;;
		-preset)
			case $2 in
				game)
					arg='-more -wine -xorg -graphics -cpu -audio'
					;;
				*)
					exit 1;;
			esac
			shift 2
			set -- $arg "$@"
			continue;;
		-reap)
			reap='&'
			args="$args --unshare-pid --die-with-parent"
			shift
			continue;;
		-interactive)
			# CVE-2017-5226
			interactive=true
			shift
			continue;;
	esac
	break
done

[ "$interactive" ] || args="$args --unshare-user --new-session"


[ "$(printf %s "$*" | wc -l)" -gt 0 ] && echo "No newlines allowd..." && exit 1
arg=$(printf '%s\n' "$@")
args="$args $(printf %s "$arg" | sed "s/'/'\\\\''/g;s/^/'/;s/$/'/" | tr '\n' ' ')"

eval "$(
	[ "$echo" ] &&
		printf "echo2 "
	[ "$reap" ] ||
		printf "exec "
)" bwrap \
--ro-bind /usr/bin /usr/bin \
--ro-bind /usr/share /usr/share/ \
--ro-bind /usr/lib /usr/lib \
--ro-bind /usr/lib32 /usr/lib32 \
--symlink lib /usr/lib64 \
--symlink /usr/lib /lib64 \
--symlink /usr/lib /lib \
--symlink /usr/bin /bin \
--symlink /usr/bin /sbin \
--tmpfs /tmp \
--tmpfs /run \
--proc /proc \
--dev /dev \
$args $reap

[ "$echo" ] && exit
[ "$reap" ] && {
	bwrap=$!

	killChildren()(
		list=$*
		while [ "$list" ]; do
			list=$(printf %s, $list)
			list=${list%?}
			list=$(ps ww -o pid= --ppid "$list")
			biglist="$biglist $list"
		done
		echo killing $biglist
		echo "$biglist" | xargs kill --
	)

	trap 'killChildren $bwrap' INT TERM HUP

	while [ -d /proc/$bwrap ]; do
		wait $bwrap
		[ $? -gt 128 ] && echo signal detected && continue
		break
	done
	echo bwrap died
}
