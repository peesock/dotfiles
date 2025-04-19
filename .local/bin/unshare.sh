#!/bin/sh
if [ "$(id -ru)" = 0 ] || capsh --current | grep -qFi cap_sys_admin; then
	echo already capable
else
	exec unshare -cm --keep-caps -- "$@"
fi
