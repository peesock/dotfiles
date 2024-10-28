#!/bin/sh
# bwrap wrapper to easily whitelist specific functions.

# Things to note:
# This script tries to add as few arguments to `bwrap` as possible,
# merely improving the cli rather than making a new one. -interactive
# and -noreap are exceptions.
# Using -interactive (which implies -noreap) can allow arbitrary code
# execution if connected to a terminal and lacking mitigations.
# Using -noreap can allow programs to fork bomb you with no guaranteed
# way to kill them, unless you --unshare-pid later and kill -9 the
# bwrap process responsible for setting the new namespace.
# Without -noreap, sending $$ kill -INT or -TERM will send TERM to all
# sandboxed children. Sending -HUP will kill -9 the entire namespace.

# *All* of /bin, /lib, and /usr/share are made visible for convenience.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME-"$HOME/.config"}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME-"$HOME/.cache"}"
export XDG_DATA_HOME="${XDG_DATA_HOME-"$HOME/.local/share"}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR-"/run/user/$(id -u)"}"

programName=${0##*/}
log(){
	printf '%s\n' "$programName: $*"
}

escapist(){
	if [ $# -eq 0 ]; then
		cat
	else
		printf "%s\0" "$@"
	fi | sed -z 's/'\''/'\''\\'\'\''/g; s/\(.*\)/'\''\1'\''/g' | tr '\0' ' '
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
			shift;;
		-noshare)
			append --unshare-user-try --unshare-ipc --unshare-pid --unshare-net --unshare-uts --unshare-cgroup-try
			shift;;
		-share)
			for arg in $2; do
				sed -zi '/^--unshare-'"$arg"'-try$\|^--unshare-'"$arg"'$/d' "$argfile"
			done
			shift 2;;
		-env)
			append --clearenv
			for var in $2; do eval 'printf -- "--setenv\0%s\0%s\0" "$var" "$'"$var"'"' ; done >> "$argfile"
			shift 2;;
		-root)
			append --unshare-user --uid 0 --gid 0 --setenv USER root --setenv HOME /root
			shift;;
		-wine)
			appath --bind-try "${WINEPREFIX-"$HOME/.wine"}" "$XDG_DATA_HOME"/lutris
			shift;;
		-proton)
			appath --bind-try "${STEAM_COMPAT_DATA_PATH:-"$XDG_DATA_HOME/proton-pfx"}" "${STEAM_COMPAT_CLIENT_INSTALL_PATH:-"$XDG_DATA_HOME/Steam"}" "${DXVK_STATE_CACHE_PATH:-"$XDG_CACHE_HOME/dxvk-cache-pool"}"
			shift;;
		-display)
			[ "$DISPLAY" ] && {
				display=$(echo "$DISPLAY" | grep -o '[0-9]' | head -n1)
				appath --ro-bind "/tmp/.X11-unix/X$display"
			}
			[ "$WAYLAND_DISPLAY" ] && {
				appath --ro-bind "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
			}
			shift;;
		-exec)
			eval "$3" | appath "$2"
			shift 3;;
		-data)
			databinder "$2" "$3" "$4"
			shift 4;;
		-net)
			printf "/etc/%s\0" hostname hosts localtime nsswitch.conf resolv.conf ca-certificates ssl | appath --ro-bind-try
			shift
			set -- -share net "$@";;
		-gpu)
			appath --dev-bind-try /dev/dri /sys/dev/char /sys/devices/pci0* /sys/module/nvidia* /dev/nvidia*
			shift;;
		-cpu)
			appath --dev-bind-try /sys/devices/system/cpu
			shift;;
		-audio)
			printf "%s\0" "$XDG_RUNTIME_DIR"/* | grep -z '/pipewire\|/pulse' | appath --ro-bind-try
			appath --ro-bind-try /etc/alsa /etc/pipewire /etc/pulse ~/.asoundrc "$XDG_CONFIG_HOME"/pipewire "$XDG_CONFIG_HOME"/pulse
			appath --dev-bind /dev/snd
			shift;;
		-theme)
			appath --bind-try /etc/fonts "$XDG_CONFIG_HOME"/fontconfig "$XDG_DATA_HOME"/fonts \
				"$HOME"/.icons "$XDG_DATA_HOME"/icons "$XDG_CONFIG_HOME"/Kvantum "$XDG_CONFIG_HOME"/qt[56]ct \
				"$HOME"/.gtkrc-2.0 "$XDG_CONFIG_HOME"/gtk-[234].0 "$XDG_CONFIG_HOME"/xsettingsd \
				"$XDG_DATA_HOME"/mime "$XDG_CONFIG_HOME"/mimeapps.list "$XDG_CONFIG_HOME"/dconf
			shift;;
		-dbus) # and portals,,, experimental (BECAUSE PORTALS STILL SUCK)
			appath --bind-try /run/dbus /etc/machine-id /etc/passwd "$XDG_CONFIG_HOME"/xdg-desktop-portal
			if [ "$DBUS_SESSION_BUS_ADDRESS" ]; then
				appath --bind-try $(echo "$DBUS_SESSION_BUS_ADDRESS" | cut -d= -f2 | cut -d, -f1)
			else
				[ "$DISPLAY" ] &&
					appath --bind-try "$(grep '^DBUS_SESSION_BUS_ADDRESS=' ~/.dbus/session-bus/"$(cat /etc/machine-id)"-"$(echo "$DISPLAY" | cut -d: -f2 | cut -d. -f1)" | cut -d= -f3 | cut -d, -f1 | cut -d\' -f1)"
			fi
# 			databinder --ro-bind-data /.flatpak-info "[Application]
# name=org.mozilla.firefox"
			# export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
			shift
			set -- -share ipc "$@";;
		-path)
			printf %s "$PATH" | tr : "\0" | appath --ro-bind-try
			shift;;
		-preset)
			case $2 in
				game)
					arg='-noshare -display -gpu -cpu -audio'
					;;
				browser)
					arg='-noshare -dbus -display -gpu -cpu -audio -theme'
					;;
				*)
					exit 1;;
			esac
			shift 2
			eval set -- "$arg" "$(escapist "$@")";;
		-noreap)
			unset reap
			shift;;
		-interactive)
			# CVE-2017-5226
			interactive=true
			unset reap
			shift;;
		-autobind)
			# Walk back from argv[] and detect the first argument that exists as a
			# path, then bind either that or its parent dir
			autobind=true
			shift;;
		*)
			break;;
	esac
done

# defaults
[ "$interactive" ] || append --unshare-user --new-session
[ "$reap" ] && append --unshare-pid --die-with-parent

[ "$autobind" ] && {
	i=$#
	unset dir sym
	while [ $i -ge 1 ]; do
		eval arg=\$$i
		[ -e "$arg" ] && {
			dir=$(realpath -mLs "$arg")
			[ -h "$dir" ] && {
				sym=$dir
				appath --bind "$sym"
				dir=$(readlink "$dir")
			}
			[ ! -d "$dir" ] && dir=${dir%/*}
			appath --bind "$dir"
			break
		}
		i=$((i - 1))
	done
	if [ "$dir" ]; then
		log autobound "$(escapist "$dir")" "$([ -n "$sym" ] && escapist "$sym")"
	else
		log autobound nothing
	fi
}

# If argv[] has "--", pass all previous args to bwrap
# For security and like 4ms of saved time, use "--"
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

	append "$1"
	shift
	i=$((i + 1))
done

eval "$datasetup"
trap - EXIT

# start bwrap
if [ "$echo" ]; then
	printf 'bwrap %s\n' "$(printf '%s\0' "$@" | cat "$argfile" - | escapist)"
	exiter
else
	fifo=$(mktemp -u)
	mkfifo "$fifo"
	(cat "$argfile" > "$fifo"; rm "$argfile" "$fifo") &
	fd=$(getfd)

	# bwrap doesn't allow extra capabilities
	[ "$(id -u)" -ne 0 ] && {
		grep -qF 'CapEff:	0000000000000000' /proc/self/status || unshare='unshare -c'
	}
	eval "$([ "$reap" ] || echo exec)" "$unshare" bwrap --args "$fd" "$(escapist "$@")$fd<" '"$fifo"' $reap
fi

[ "$reap" ] && {
	pid=$!

	killchildren()(
	log signal $(($? - 128)) received
		if [ "$1" = '9' ]; then
			log kill -9ing: "$2"
			kill -s 9 -- "$2"
		else
			export LIBPROC_HIDE_KERNEL=
			export LC_ALL=C
			pidns=$(ps -ww -o pidns= --ppid "$2" | grep '[0-9]' | head -n1)
			[ "$pidns" ] || {
				log child already died
				exit 1
			}
			list=$(ps -ww -e -o pidns=,pid= | grep '^\s*'"$pidns"'\s' | awk '{print $2}')
			log kill -"$1"ing: $list &
			kill -s "$1" -- $list
		fi
	)

	trap 'killchildren 15 $pid' TERM INT
	trap 'killchildren 9 $pid' HUP

	while ps -p $pid >/dev/null; do
		wait $pid
		status=$?
		[ $? -gt 128 ] && continue
		return "$status"
	done
}
