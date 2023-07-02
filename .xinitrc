#!/bin/sh
# startup services for display sessions

setbg --stretch & # set background
xrandr --dpi 102 # Set DPI.
input.sh # fixes keyboard assshittery

xrdb ${XDG_CONFIG_HOME:-$HOME/.config}/x11/xresources & xrdbpid=$!	# use Xresources colors/settings on startup

xset s on
xset s noblank # prevents monitor from shutting off (nvidia + monitor bug of mine), displays pattern instead (unless screen saver/locker is set)
xset -dpms # disable dpms; i want to configure everything in my Xorg config

export XORG_SCREENSAVER_CYCLE=10
xset s 900 $XORG_SCREENSAVER_CYCLE # set screen saver/locker timeout
xss-lock -n 'apock warn' -- apock &

xsetroot -cursor_name left_ptr # ensures correct cursor on X root window

sxhkd &
dunst &
unclutter --ignore-scrolling --start-hidden &
mpd &
# cmst -m &
# nm-applet &
udiskie &
qbittorrent &
picom &
syncthing --no-browser &

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

# autostart programs that must be launched after the WM
