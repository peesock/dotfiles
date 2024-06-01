#!/bin/sh
# bwrap wrapper to easily whitelist specific functions.

# Things to note:
# This script tries to add as few arguments to `bwrap` as possible,
# merely improving the cli rather than making a new one. -interactive
# and -noreap are exceptions.
# Using -interactive can allow arbitrary code execution if connected to
# a terminal and lacking mitigations.
# Using -noreap can allow programs to fork bomb you with no effective
# means of death, unless you re-unshare pid namespace later on and
# kill -9 the bwrap parent.
# Without -noreap, sending $$ kill -INT and kill -TERM will send their
# respective signals to all sandboxed children. Sending HUP will
# KILL every child.
# *All* of /bin, /lib, and /usr/share are made visible.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME-"$HOME/.config"}"
export XDG_DATA_HOME="${XDG_DATA_HOME-"$HOME/.local/share"}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR-"/run/user/$(id -u)"}"
export WINEPREFIX="${WINEPREFIX-"$HOME/.wine"}"

echo2(){
	var=$(printf '%s ' "$@")
	printf '%s\n' "${var%?}"
	var=
}

programName=$(basename "$0")
log(){
	echo2 "$programName:" "$@"
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

getfd(){
	ls -1 /dev/fd | sed 's/.*\///' | sort -n | awk 'n<$1{exit}{n=$1+1}END{print n}'
}

databinder(){
	# --file, --bind-data, --ro-bind-data, location, data
	fd=$(getfd)
	args="$args $1 $fd $2"
	append "$1" "$fd" "$2"
	datasetup="$datasetup exec $fd<<EOF
$3
EOF
"
}

argfile=$(mktemp)

exiter(){
	[ -f "$argfile" ] && rm "$argfile"
	exit
}
trap exiter EXIT

append(){
	printf "%s\0" "$@" >> "$argfile"
}
appath(){
	opt=$1
	shift
	if [ $# -gt 0 ]; then
		for arg; do
			printf "%s\0%s\0%s\0" "$opt" "$arg" "$arg"
		done
	else # when piped
		sed -z 's/\(.*\)/'"$opt"'\x0\1\x0\1/'
	fi
} >> "$argfile"

append \
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
--dev /dev

# defaults
reap='&'

while true; do
	case "$1" in
		-echo)
			echo=true
			shift
			continue;;
		-noshare)
			append --unshare-user-try --unshare-ipc --unshare-pid --unshare-net --unshare-uts --unshare-cgroup-try
			shift
			continue;;
		-share)
			for arg in $2; do
				sed -zi '/^--unshare-'"$arg"'-try$\|^--unshare-'"$arg"'$/d' "$argfile"
			done
			shift 2
			continue;;
		-env)
			append --clearenv
			for var in $2; do eval 'printf -- "--setenv\0%s\0%s\0" "$var" "$'"$var"'"' ; done >> "$argfile"
			shift 2
			continue;;
		-root)
			append --unshare-user --uid 0 --gid 0 --setenv USER root --setenv HOME /root
			shift
			continue;;
		-wine)
			appath --bind-try "$WINEPREFIX" "$XDG_DATA_HOME"/lutris
			shift
			continue;;
		-display)
			[ "$DISPLAY" ] && {
				display=$(echo "$DISPLAY" | cut -c2-)
				appath --bind "/tmp/.X11-unix/X$display"
			}
			[ "$WAYLAND_DISPLAY" ] && {
				appath --bind "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
			}
			shift
			continue;;
		-exec)
			eval "$3" | appath "$2"
			shift 3
			continue;;
		-data)
			databinder "$2" "$3" "$4"
			shift 4
			continue;;
		-net)
			printf "/etc/%s\0" hostname hosts localtime nsswitch.conf resolv.conf ca-certificates ssl | appath --ro-bind-try
			shift
			set -- -share net "$@"
			continue;;
		-gpu)
			find /dev -maxdepth 1 -name nvidia\* -print0 | appath --dev-bind-try
			appath --dev-bind-try /dev/dri /sys/dev/char /sys/devices/pci0*
			shift
			continue;;
		-cpu)
			appath --dev-bind-try /sys/devices/system/cpu
			shift
			continue;;
		-audio)
			find "$XDG_RUNTIME_DIR" -maxdepth 1 -print0 | grep -z '/pipewire\|/pulse' | appath --ro-bind-try
			appath --ro-bind-try /etc/alsa /etc/pipewire /etc/pulse ~/.asoundrc "$XDG_CONFIG_HOME"/pipewire "$XDG_CONFIG_HOME"/pulse
			shift
			continue;;
		-theme)
			appath --bind-try /etc/fonts "$XDG_CONFIG_HOME"/fontconfig "$XDG_DATA_HOME"/fonts \
				"$HOME"/.icons "$XDG_DATA_HOME"/icons "$XDG_CONFIG_HOME"/Kvantum "$XDG_CONFIG_HOME"/qt[56]ct \
				"$HOME"/.gtkrc-2.0 "$XDG_CONFIG_HOME"/gtk-[234].0 "$XDG_CONFIG_HOME"/xsettingsd \
				"$XDG_DATA_HOME"/mime "$XDG_CONFIG_HOME"/mimeapps.list "$XDG_CONFIG_HOME"/dconf
			shift
			continue;;
		-dbus) # and portals,,, experimental (BECAUSE PORTALS STILL SUCK)
			printf "%s\0" /tmp/dbus-* /run/dbus /etc/machine-id /etc/passwd "$XDG_CONFIG_HOME"/xdg-desktop-portal | appath --bind-try
# 			databinder --ro-bind-data /.flatpak-info "[Application]
# name=org.mozilla.firefox"
			# export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
			shift
			set -- -share ipc "$@"
			continue;;
		-path)
			printf %s "$PATH" | tr : "\0" | appath --ro-bind-try
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
						sym=$dir
						appath --bind "$sym"
						dir=$(readlink "$dir")
					}
					[ ! -d "$dir" ] && dir=$(dirname "$dir")
					appath --bind "$dir"
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
[ "$interactive" ] || append --unshare-user --new-session
[ "$reap" ] && append --unshare-pid --die-with-parent

# If argv[] has "--", pass all previous args to bwrap
i=0
while true; do
	[ $# -eq 1 ] && {
		[ $i -gt 0 ] && {
			eval set -- "$(tail -zn$i "$argfile" | escapist)" '"$1"'
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

eval "$datasetup"
trap - EXIT
# start bwrap
$(if [ "$echo" ]; then
		printf "echo2 "
	else
		printf "eval %s" '(cat '"$argfile"'; rm '"$argfile"') |'
	fi
) bwrap "$([ "$echo" ] && escapist <"$argfile" || echo --args 0)" "$(escapist "$@")" $reap

[ "$echo" ] && { rm "$argfile"; exit; }
[ "$reap" ] && {
	pid=$!

	killchildren()(
		export LIBPROC_HIDE_KERNEL=
		export LC_ALL=C
		log signal received
		pidns=$(ps -ww -o pidns= --ppid "$2" | grep '[0-9]' | head -n1)
		[ "$pidns" ] || {
			log child already died
			exit 1
		}
		list=$(ps -ww -e -o pidns=,pid= | grep '^\s*'"$pidns"'\s' | awk '{print $2}')
		log kill -"$1"ing: $list &
		kill -s "$1" -- $list
	)

	trap 'killchildren 2 $pid' INT
	trap 'killchildren 15 $pid' TERM
	trap 'killchildren 9 $pid' HUP

	while [ -d /proc/$pid ]; do
		wait $pid
		[ $? -gt 128 ] && continue
		break
	done
}
