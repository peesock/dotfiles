#!/bin/sh
[ "$DBUS_SESSION_BUS_ADDRESS" ] || {
	echo 'static DBUS_SESSION_BUS_ADDRESS not set. dbus service will not activate'
	exit 0
}
[ "$DINIT_FD" ] || {
	echo 'this is shrimply impossible.'
	exit 0
}
exec dbus-daemon --session --nopidfile --nofork \
	--address="$DBUS_SESSION_BUS_ADDRESS" --print-address="$DINIT_FD"
