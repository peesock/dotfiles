#!/bin/sh -m
browser-sync firefox ~/.mozilla/firefox
firefox-developer-edition &
browser-sync -d -e firefox ~/.mozilla/firefox &
fg %-
