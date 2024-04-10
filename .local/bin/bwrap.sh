#!/bin/sh
# bwrap boilerplate. not meant to work everywhere, only work well enough to quickly sandbox my personal stuff.

CONFIG=${XDG_CONFIG_HOME-"$HOME/.config"}
DATA=${XDG_DATA_HOME-"$HOME/.local/share"}
RUNTIME=${XDG_RUNTIME_DIR-"/run/user/$(id -u)"}
WINEPREFIX=${WINEPREFIX-"$HOME/.wine"}

echo2(){
	var=$(printf '%s ' "$@")
	printf '%s\n' "${var%?}"
	var=
}

log(){
	echo2 "$(basename "$0"):" "$@"
}

escapist(){
	tr="tr '\0' ' '"
	if [ $# -eq 0 ]; then
		print="cat"
	else
		print='printf "%s\0" "$@"'
		[ $# -eq 1 ] && tr="tr -d '\0'"
	fi
	eval "$print" | sed -z 's/'\''/'\''\\'\'\''/g; s/\(.\+\)/'\''\1'\''/g' | eval "$tr"
}

executer(){
	arg=$(eval "$2" | while read -r file; do
		printf '%s\0' "$1" "$file" "$file"
	done | escapist)
	args="$args $arg"
}

for var in CONFIG DATA RUNTIME WINEPREFIX; do
	eval $var='$(escapist "'\$$var'")' # SLOW..........................
done

# defaults
reap='&'

while true; do
	case "$1" in
		-echo)
			echo=true
			shift
			continue;;
		-noshare)
			args="$args --unshare-user-try --unshare-ipc --unshare-pid --unshare-net --unshare-uts --unshare-cgroup-try"
			shift
			continue;;
		-share)
			for arg in $2; do
				args=$(echo "$args" | sed 's/--unshare-'"$arg"'-try \|--unshare-'"$arg"' //g')
			done
			shift 2
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
			args="$args --bind-try $WINEPREFIX $WINEPREFIX --bind-try $DATA/lutris $DATA/lutris"
			shift
			continue;;
		-exec)
			executer "$2" "$3"
			shift 3
			continue;;
		-xorg)
			args="$args --bind /tmp/.X11-unix /tmp/.X11-unix"
			executer --ro-bind 'find /tmp -maxdepth 1 | grep "/.X[0-9]\+-lock$"'
			shift
			continue;;
		-net)
			args="$args --share-net"
			executer --ro-bind-try 'printf "/etc/%s\n" hostname hosts localtime nsswitch.conf resolv.conf'
			shift
			continue;;
		-gpu)
			executer --dev-bind-try 'find /dev -maxdepth 1 -name nvidia\*; echo /dev/dri'
			shift
			continue;;
		-cpu)
			args="$args --dev-bind-try /sys/devices/system/cpu /sys/devices/system/cpu"
			shift
			continue;;
		-audio)
			executer --ro-bind-try "find $RUNTIME -maxdepth 1 | grep '/pipewire\|/pulse'
				printf '%s\n' /etc/alsa /etc/pipewire /etc/pulse ~/.asoundrc $CONFIG/pipewire $CONFIG/pulse"
			shift
			continue;;
		-theme)
			executer --ro-bind-try "printf '%s\n' /etc/fonts $CONFIG/fontconfig $DATA/fonts \
				$HOME/.icons $DATA/icons $CONFIG/Kvantum $CONFIG/qt[56]ct \
				$HOME/.gtkrc-2.0 $CONFIG/gtk-[234].0"
			shift
			continue;;
		-path)
			executer --ro-bind-try 'echo "$PATH" | tr : "\n"'
			shift
			continue;;
		-preset)
			case $2 in
				game)
					arg='-noshare -wine -xorg -gpu -cpu -audio'
					;;
				*)
					exit 1;;
			esac
			shift 2
			set -- $arg "$@"
			continue;;
		-noreap)
			unset reap
			shift
			continue;;
		-interactive)
			# CVE-2017-5226
			interactive=true
			unset reap
			shift
			continue;;
		-autobind)
			# Walk back from argv[] and detect the first argument that exists as a
			# path, then bind either that or its parent dir
			i=$#
			unset dir sym
			while [ $i -gt 1 ]; do
				eval arg=\$$i
				[ -e "$arg" ] && {
					dir=$(realpath -mLs "$arg")
					[ -h "$dir" ] && {
						sym=$(escapist "$dir")
						args="$args --bind $sym $sym"
						dir=$(readlink "$dir")
					}
					[ ! -d "$dir" ] && dir=$(dirname "$dir")
					dir=$(escapist "$dir")
					args="$args --bind $dir $dir"
					break
				}
				i=$((i - 1))
			done
			if [ "$dir" ]; then
				log autobound "$dir" "$sym"
			else
				log autobound nothing
			fi
			shift
			continue;;
	esac
	break
done

# defaults
[ "$interactive" ] || args="$args --unshare-user --new-session"
[ "$reap" ] && args="$args --unshare-pid --die-with-parent"

args="$args $(escapist "$@")"

# i=1
# while [ $i -le $# ]; do
# 	eval [ '"$'$i'"' = -- ] && explicit=true && break
# 	i=$((i + 1))
# done
# [ "$explicit" = true ] && shift $i

$(
	if [ "$echo" ]; then
		printf "echo2 "; else
		printf "eval "
	fi
	[ "$reap" ] ||
		printf "exec "
) bwrap \
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
"$args" $reap

[ "$echo" ] && exit
[ "$reap" ] && {
	pid=$!

	killChildren()(
		export LIBPROC_HIDE_KERNEL=
		export LC_ALL=C
		log signal received
		pidns=$(ps -ww -o pidns= --ppid "$1" | grep '[0-9]' | head -n1)
		[ "$pidns" ] || {
			log child already died
			exit 1
		}
		list=$(ps -ww -e -o pidns=,pid= | grep '^\s*'"$pidns"'\s' | awk '{print $2}')
		log killing $list &
		kill -- $list
	)

	trap 'killChildren $pid' INT TERM HUP

	while [ -d /proc/$pid ]; do
		wait $pid
		[ $? -gt 128 ] && continue
		break
	done
}
