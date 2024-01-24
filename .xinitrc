#!/bin/sh
# startup services for display sessions

setbg --stretch & # set background
# xrandr --dpi 102 # Set DPI.
xorg.sh # fixes keyboard assshittery

xrdb ${XDG_CONFIG_HOME:-$HOME/.config}/x11/xresources & xrdbpid=$!	# use Xresources colors/settings on startup

xsetroot -cursor_name left_ptr # ensures correct cursor on X root window
unclutter --ignore-scrolling --start-hidden &

# restart, so it has new Xorg env vars
sv x "$HOME/.local/var/run/xapps"
runsv "$HOME/.local/var/run/xapps" &
until svu u xapps; do sleep 0.1; done

# Ensure that xrdb has finished running before moving on to start the WM/DE.
[ -n "$xrdbpid" ] && wait "$xrdbpid"

# Now start the desktop
session=${1:-awesome}

case $session in
qtile) exe=qtile ;;
awm | awesome) exe=awesome ;;
kde | plasma) exe=startplasma-x11 ;;
xfce | xfce4) exe=startxfce4 ;;
bspwm) exe=bspwm ;;
# No known session, try to run it as command
*) exe="$1" ;;
esac
mkdir -p "$HOME/.cache/desktop-logs"
exec $exe >"$HOME/.cache/desktop-logs/log-$(date +%s)" 2>&1
