#!/bin/sh
set -e
# bwrap boilerplate. not meant to work everywhere, only work well enough to quickly sandbox my personal stuff.
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR-"/run/user/$(id -u)"}
WINEPREFIX=${WINEPREFIX-"$HOME/.wine"}
executer(){
	arg=$(eval "$2" | while read -r file; do
		echo "$1 $file $file"
	done)
	args="$args $arg"
}
while true; do
	case "$1" in
		-echo)
			alias bwrap='echo bwrap'
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
			args="$args --bind-try $WINEPREFIX $WINEPREFIX"
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
		-nvidia)
			executer --dev-bind-try 'find /dev -maxdepth 1 -name nvidia\*'
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
					arg='-more -wine -xorg -nvidia -cpu -audio'
					;;
				*)
					exit 1;;
			esac
			shift 2
			set -- $arg "$@"
			continue;;
	esac
	break
done
bwrap \
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
--die-with-parent \
$args \
"$@"
