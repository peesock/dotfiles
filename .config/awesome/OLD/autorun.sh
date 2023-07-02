#!/bin/sh

run() {
  if ! pgrep -f "$1" ;
  then
    "$@"&
  fi
}

#run "picom --config  $HOME/.config/picom/picom-blur.conf"
#run "feh --randomize --bg-fill /usr/share/wallpapers/garuda-wallpapers/"
#run "lxqt-session"
#run "lxpolkit"
