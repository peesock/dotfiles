#!/bin/sh
browser-sync firefox ~/.mozilla/firefox >/dev/null
firefox-developer-edition & ffpid=$!
browser-sync -d -e firefox ~/.mozilla/firefox >/dev/null &
trap 'kill -s INT $ffpid' INT TERM
wait
