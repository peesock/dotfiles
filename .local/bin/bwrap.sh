#!/bin/sh
# bwrap boilerplate. not meant to work everywhere, only work well enough to quickly sandbox my personal stuff.
# todo: finish putting args into argfile

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME-"$HOME/.config"}"
export XDG_DATA_HOME="${XDG_DATA_HOME-"$HOME/.local/share"}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR-"/run/user/$(id -u)"}"
export WINEPREFIX="${WINEPREFIX-"$HOME/.wine"}"

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
	eval "$print" | sed -z 's/'\''/'\''\\'\'\''/g; s/\(.*\)/'\''\1'\''/g' | eval "$tr"
}

executer(){
	args="$args $(eval "$2" | sed -z 's/'\''/'\''\\'\'\''/g; s/\(.*\)/'\''\1'\''/g; s/\(.\+\)/'"$1"' \1 \1 /' | tr -d '\0')"
}

getfd(){
	ls -1 /dev/fd | sed 's/.*\///' | sort -n | awk 'n<$1{exit}{n=$1+1}END{print n}'
}

databinder(){
	# --file, --bind-data, --ro-bind-data, location, data
	fd=$(getfd)
	args="$args $1 $fd $2"
	datasetup="$datasetup exec $fd<<EOF
\$3
EOF
"
}

argfile=$(mktemp)

exiter(){
	[ -f "$argfile" ] && rm "$argfile"
	exit
}
trap exiter EXIT

CONFIG=$XDG_CONFIG_HOME
DATA=$XDG_DATA_HOME
RUNTIME=$XDG_RUNTIME_DIR
WINE=$WINEPREFIX
# vars to add escape sequences to
vars="CONFIG DATA RUNTIME WINE"
eval "$(for var in $vars; do eval printf '%s="%s"\\0' '$var' '"$'"$var"'"'; done | sed -z 's/'\''/'\''\\'\'\''/g; s/\(.\+=\)\(.*\)/\1'\''\2'\''/g' | tr '\0' '\n')"

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
			arg=$(for var in $2; do eval 'printf -- "--setenv %s %s " "$var" "$(escapist "$'"$var"'")"' ; done)
			args="$args --clearenv $arg"
			shift 2
			continue;;
		-root)
			args="$args --unshare-user --uid 0 --gid 0 --setenv USER root --setenv HOME /root"
			shift
			continue;;
		-wine)
			args="$args --bind-try $WINE $WINE --bind-try $DATA/lutris $DATA/lutris"
			shift
			continue;;
		-display)
			[ "$DISPLAY" ] && {
				display=$(echo "$DISPLAY" | cut -c2-)
				args="$args --bind /tmp/.X11-unix/X$display /tmp/.X11-unix/X$display"
			}
			[ "$WAYLAND_DISPLAY" ] && {
				args="$args --bind $RUNTIME/$WAYLAND_DISPLAY $RUNTIME/$WAYLAND_DISPLAY"
			}
			shift
			continue;;
		-exec)
			executer "$2" "$3"
			shift 3
			continue;;
		-data)
			databinder "$2" "$3" "$4"
			shift 4
			continue;;
		-net)
			executer --ro-bind-try 'printf "/etc/%s\0" hostname hosts localtime nsswitch.conf resolv.conf ca-certificates ssl'
			shift
			set -- -share net "$@"
			continue;;
		-gpu)
			executer --dev-bind-try 'find /dev -maxdepth 1 -name nvidia\* -print0; printf "%s\0" /dev/dri /sys/dev/char /sys/devices/pci0*'
			shift
			continue;;
		-cpu)
			args="$args --dev-bind-try /sys/devices/system/cpu /sys/devices/system/cpu"
			shift
			continue;;
		-audio)
			executer --ro-bind-try "find $RUNTIME -maxdepth 1 -print0 | grep -z '/pipewire\|/pulse'
				printf '%s\0' /etc/alsa /etc/pipewire /etc/pulse ~/.asoundrc $CONFIG/pipewire $CONFIG/pulse"
			shift
			continue;;
		-theme)
			executer --bind-try "printf '%s\0' /etc/fonts $CONFIG/fontconfig $DATA/fonts \
				$HOME/.icons $DATA/icons $CONFIG/Kvantum $CONFIG/qt[56]ct \
				$HOME/.gtkrc-2.0 $CONFIG/gtk-[234].0 $CONFIG/xsettingsd $DATA/mime $CONFIG/mimeapps.list \
				$CONFIG/dconf"
			shift
			continue;;
		-dbus) # and portals,,, experimental (BECAUSE PORTALS STILL SUCK)
			executer --bind-try 'printf "%s\0" /tmp/dbus-* /run/dbus /etc/machine-id /etc/passwd $CONFIG/xdg-desktop-portal'
# 			databinder --ro-bind-data /.flatpak-info "[Application]
# name=org.mozilla.firefox"
			# export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
			shift
			set -- -share ipc "$@"
			continue;;
		-path)
			executer --ro-bind-try 'echo "$PATH" | tr : "\0"'
			shift
			continue;;
		-preset)
			case $2 in
				game)
					arg='-noshare -wine -display -gpu -cpu -audio'
					;;
				browser)
					arg='-noshare -net -dbus -display -gpu -cpu -audio -theme'
					;;
				*)
					exit 1;;
			esac
			shift 2
			eval set -- "$arg" "$(escapist "$@")"
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
args="\
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
$args"

# If argv[] has "--", pass all previous args to bwrap
i=0
while true; do
	[ $# -eq 1 ] && {
		[ $i -gt 0 ] && {
			eval set -- "$(tail -zn$i "$argfile" | escapist)" "$1"
			tmp=$(mktemp)
			head -zn-$i "$argfile" > "$tmp"
			mv "$tmp" "$argfile"
		}
		break
	}
	[ "$1" = "--" ] && break

	printf '%s\0' "$1" >> "$argfile"
	shift
	i=$((i + 1))
done

eval 'printf "%s\0" '"$args"' > '"$argfile"

eval "$datasetup"
trap - EXIT
# start bwrap
$(
	if [ "$echo" ]; then
		printf "echo2 "
		rm "$argfile"
	else
		printf "eval "
		printf "%s" '(cat '"$argfile"'; rm '"$argfile"') |'
	fi
) bwrap --args 0 "$(escapist "$@")" $reap

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
