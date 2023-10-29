#!/bin/sh
# vim: ft=sh

# custom environment variables
export TERMINAL=kitty
export BROWSER=firefox.sh
export SCREENSHOTS=$HOME/pics/screenshots
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$HOME/.local/bin:$PATH
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANPAGER="less"
export PAGER="less"
export QT_QPA_PLATFORMTHEME=qt5ct
export GTK_THEME= 'Dracula' # 'Sweet-Dark-v40'
export GOPATH="$HOME/.local/share/go/"
export DBUS_SESSION_BUS_ADDRESS="autolaunch:" # don't ask me how dbus works
# export GTK_USE_PORTAL=1
export MPD_HOST="$HOME/.local/share/mpd/socket"
export NBRC_PATH="$HOME/.config/nb/nbrc"
export NB_DIR="$HOME/.config/nb/"
