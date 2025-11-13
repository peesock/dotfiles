#!/bin/sh

networkDev=$(ip -j r get 9.9.9.9 | jq -r '.[0] | .dev, .gateway')
ipnet=$(echo "$networkDev" | tail -n1)
networkDev=$(echo "$networkDev" | head -n1)
ipnet="$ipnet/$(ip -4 -j a show dev eth0 | jq '.[0].addr_info.[0].prefixlen')"

ip=$(echo "$ipnet" | cut -d/ -f1)
cidr=$(echo "$ipnet" | cut -d/ -f2)

# runs as sudo!
setNetwork()(
	i=0
	fifo1=$1
	fifo2=$2
	fifopid=$3
	pid=$4
	wireguard=$5
	signal=$6
	exiter(){
		rm "$fifo1" "$fifo2"
		kill -s 9 "$fifopid"
		[ "$signal" ] && kill -s USR1 "$pid"
	}
	trap exiter EXIT
	trap exit TERM INT
	while [ "$(readlink /proc/$$/ns/net)" = "$(readlink "/proc/$pid/ns/net")" ]; do
		[ "$i" -ge 50 ] && echo "namespace checking timeout" && return 1
		sleep 0.1
		i=$((i + 1))
	done
	[ -d /proc/"$pid" ] || return 1
	ip l add vpn-ipvlan link "$networkDev" type ipvlan mode l2
	ip l set vpn-ipvlan netns "$pid"
	nsenter --net=/proc/"$pid"/ns/net sh -c '
	ip l set lo up
	while read -r ip; do
		msg=$(ip a add "$ip/$1" dev vpn-ipvlan 2>&1) && break ||
		{
			echo "$msg" | grep -i -q "error.*assigned" && continue
			exit 1
		}
	done
	ip l set vpn-ipvlan up
	echo netns lan ip: "$ip" >&2
	' sh "$cidr" <"$fifo2" || { echo "epic fail"; exit 2; }
	[ "$wireguard" ] && {
		ip l add vpn-tun type wireguard
		ip l set vpn-tun netns "$pid"
		nsenter --net=/proc/"$pid"/ns/net sh -c '
		wg setconf vpn-tun "$1"
		ip a add 10.0.0.1/24 dev vpn-tun
		ip l set vpn-tun up
		ip r add default dev vpn-tun
		' sh "$wireguard"
		echo wireguard tunnel ip: 10.0.0.1/24
	}
)

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
Fifo1=$(mktemp -u)
Fifo2=$(mktemp -u)
mkfifo "$Fifo1" "$Fifo2"
for n in $(seq "$bot" "$top"); do
	ipRecurse "$i" "$baseip.$n"
done > "$Fifo1" &

unshare -rmpf --mount-proc --kill-child -- sh -c '
i=1
while read -r _ip; do
	(ping -4 -q -c 1 -W 1 "$_ip" 2>&1 | grep -qiF "100% packet loss" && echo "$_ip")
	[ $i -eq 16 ] && wait && i=1
	i=$((i + 1))
done
' sh <"$Fifo1" >"$Fifo2" &

exiter(){
	rm "$Fifo1" "$Fifo2"
}
trap exiter EXIT
trap exit TERM INT

# now exec stuff
[ "$nsPid" ] && exec $sudo "$0" 1 "$Fifo1" "$Fifo2" "$!" "$nsPid" "$wireguard"

# if pid not specified, run a command
[ "$#" -le 0 ] && echo "specify -p <pid> or write a command" && exit 1

$sudo "$0" 1 "$Fifo1" "$Fifo2" "$!" "$$" "$wireguard" true &
if [ "$su" ]; then
	unargs=-n
else
	unargs=-cn
fi
exec unshare $unargs -- sh -c 'trap "trap - USR1; exec \"\$@\"" USR1; waitpid $$ & wait' sh "$@"
