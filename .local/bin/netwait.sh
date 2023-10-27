#!/bin/sh
interface=${1-eth0}
export LC_ALL=C
while true; do
	ip a show "$interface" | grep "inet " >/dev/null && break
	sleep 0.1
done
