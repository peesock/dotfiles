#!/bin/sh
# wait until the network is assigned an IP address
export LC_ALL=C
interface=$1
while [ -z "$interface" ]; do
	interface="$(ip route | awk '/^default via/ {print $5; exit}')"
done
while true; do
	ip a show "$interface" | grep "inet " >/dev/null && break
done
