#!/bin/sh

networkDev=eth0
ipnet='192.168.4.0/22'

ip=$(echo "$ipnet" | cut -d/ -f1)
cidr=$(echo "$ipnet" | cut -d/ -f2)

# runs as sudo!
setNetwork(){
	i=0
	while [ "$(readlink /proc/$$/ns/net)" = "$(readlink "/proc/$2/ns/net")" ]; do
		[ "$i" -ge 50 ] && echo "namespace checking timeout" && return 1
		sleep 0.1
		i=$((i + 1))
	done
	[ -d /proc/"$2" ] || return 1
	ip l add vpn-ipvlan link "$networkDev" type ipvlan mode l2
	ip l set vpn-ipvlan netns "$2"
	nsenter --net=/proc/"$2"/ns/net sh -c '
	ip l set lo up
	ip a add "$1/$2" dev vpn-ipvlan
	ip l set vpn-ipvlan up
	' sh "$1" "$cidr"
	echo netns lan ip: "$1" >&2
	[ "$3" ] && {
		ip l add vpn-tun type wireguard
		ip l set vpn-tun netns "$2"
		nsenter --net=/proc/"$2"/ns/net sh -c '
		wg setconf vpn-tun "$1"
		ip a add 10.0.0.1/24 dev vpn-tun
		ip l set vpn-tun up
		ip r add default dev vpn-tun
		' sh "$3"
		echo wireguard tunnel ip: 10.0.0.1/24
	}
}

[ "$1" = 1 ] && {
	shift
	setNetwork "$@"
	exit
}

# args
if [ "$(id -ru)" = 0 ] || capsh --current | grep -qFi cap_sys_admin; then
	su=true
fi
[ "$su" ] || sudo=sudo
for arg; do
	case $arg in
		-p)
			nsPid=$2
			shift 2
			break;;
		-s)
			sudo=$2
			shift 2;;
		-w)
			wireguard=$2
			shift 2;;
		--)
			shift
			break;;
		*)
			break;;
	esac
done

# horribly epic way of getting an available ip addr
# first get the range
c=$cidr
for i in $(seq 4); do
tmp=$((c - 8))
[ "$tmp" -lt 0 ] && c=$((8 - c)) && break
c=$tmp
done
bot=$(echo "$ip" | cut -d. -f$i)
top=$((((1 << c) - 1) + bot))
baseip=$(echo "$ip" | cut -d. -f-$((i - 1)))
ipRecurse(){
	[ "$1" = 4 ] && {
		echo "$2"
		return
	}
	for n in $(seq 1 254 | tac); do
		ipRecurse $(($1 + 1)) "$2.$n"
	done
}
ipList=$(mktemp -u)
mkfifo "$ipList"
(for n in $(seq "$bot" "$top"); do
	ipRecurse "$i" "$baseip.$n"
done | tail -n+2 | head -n-3) > "$ipList" &

tmpFifo=$(mktemp -u)
mkfifo "$tmpFifo"
exiter(){
	rm "$ipList" "$tmpFifo"
}
trap exiter EXIT
trap exit TERM INT

# ping the range 16 addrs at a time with 1s timeout
unshare -rmpf --mount-proc --kill-child -- sh -c '
i=1
while read -r _ip; do
	(ping -4 -q -c 1 -W 1 "$_ip" 2>&1 | grep -qiF "100% packet loss" && echo "$_ip")
	[ $i -eq 16 ] && wait && i=1
	i=$((i + 1))
done
' sh <"$ipList" >"$tmpFifo" &
newIp=$(head -n1 <"$tmpFifo")
kill -s 9 $!
[ "$newIp" ] || {
	echo "no free ip's detected!?!!??!"
	exit 2
}

# now exec stuff
[ "$nsPid" ] && exec $sudo "$0" 1 "$newIp" "$nsPid" "$wireguard"

# if pid not specified, run a command
[ "$#" -le 0 ] && echo "specify -p <pid> or write a command" && exit 1

$sudo "$0" 1 "$newIp" "$$" "$wireguard" &
exiter
if [ "$su" ]; then
	exec unshare -n -- "$@"
else
	exec unshare -cn -- "$@"
fi
