#!/bin/sh
# bwrap boilerplate. not meant to work everywhere, only work well enough to quickly sandbox my personal stuff.
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
		-root)
			args="$args --unshare-user --uid 0 --gid 0 --setenv USER root --setenv HOME /root"
			shift
			continue;;
		-wine)
			args="$args --bind-try ${WINEPREFIX-$HOME/.wine} ${WINEPREFIX-$HOME/.wine}"
			shift
			continue;;
		-xorg)
			args="$args --bind-try /tmp/.X11-unix /tmp/.X11-unix"
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
		-audio)
			executer --bind 'find /run/user/$(id -u) -maxdepth 1 | grep "/pipewire\|/pulse" ; echo /dev/snd'
			shift
			continue;;
	esac
	break
done
bwrap \
--ro-bind /usr/bin /usr/bin \
--ro-bind /usr/share /usr/share/ \
--ro-bind /usr/lib /usr/lib \
--ro-bind /usr/lib32 /usr/lib32 \
--symlink /usr/lib /usr/lib64 \
--symlink /usr/lib /lib64 \
--symlink /usr/lib /lib \
--symlink /usr/bin /bin \
--symlink /usr/bin /sbin \
--tmpfs /tmp \
--tmpfs /run \
--proc /proc \
--dev /dev \
$args \
"$@"
