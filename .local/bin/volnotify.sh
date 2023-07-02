#!/bin/sh
notify-send -r 13 -u low -t 1000 "$1:" "$(amixer -D "${2-default}" sget "$1" | grep '%\]' | awk -F'[][]' '{ print $2 }' | head -n1)"
