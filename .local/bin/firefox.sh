#!/bin/sh
browser-sync firefox-developer-edition firefox ~/.mozilla/firefox
firefox-developer-edition &
browser-sync -d -e firefox-developer-edition firefox ~/.mozilla/firefox &
wait
