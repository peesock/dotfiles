#!/bin/sh

xset -q | grep "Caps Lock:\s*on" && xdotool key Caps_Lock
setxkbmap -option compose:menu
setxkbmap -option caps:escape_shifted_capslock
xset r rate 300 50 # keyboard 300ms delay and 50hz repeat rate

xset s on
xset s noblank # prevents monitor from shutting off (nvidia + monitor bug of mine), displays pattern instead (unless screen saver/locker is set)
xset -dpms # disable dpms; i shrimply don't want it

xset s 900 15 # set screen saver/locker timeout
setsid -f xss-lock -n 'apock warn' -- apock xscreensaver
