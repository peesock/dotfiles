#!/bin/sh

# Map the caps lock key to super, and map the menu key to right super.
setxkbmap -option caps:escape,altwin:menu_win
# When caps lock is pressed only once, treat it as escape.
# killall xcape 2>/dev/null ; xcape -e 'Super_L=Escape'
# Turn off caps lock if on since there is no longer a key for it.
xset -q | grep "Caps Lock:\s*on" && xdotool key Caps_Lock
xset r rate 300 50 # keyboard 300ms delay and 50hz repeat rate

xset s on
xset s noblank # prevents monitor from shutting off (nvidia + monitor bug of mine), displays pattern instead (unless screen saver/locker is set)
xset -dpms # disable dpms; i shrimply don't want it

xset s 900 15 # set screen saver/locker timeout
setsid -f xss-lock -n 'apock warn' -- apock xss -e xscreensaver pipes
