#!/bin/sh
memory-sync firefox ~/.mozilla/firefox
firefox-developer-edition &
memory-sync -d -e firefox ~/.mozilla/firefox -p $!
