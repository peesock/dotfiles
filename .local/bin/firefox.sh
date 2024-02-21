#!/bin/sh
memory-sync firefox ~/.mozilla/firefox
firefox-developer-edition &
memory-sync -D -e firefox ~/.mozilla/firefox -p $!
