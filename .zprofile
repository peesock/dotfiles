#!/bin/sh
# vim: ft=sh
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/dbus.sock"

export TERMINAL=kitty
export BROWSER=firefox.sh
export SCREENSHOTS="$HOME/pics/screenshots"
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export PATH="$HOME/.local/bin:$PATH"
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANPAGER="nvim +Man!"
export PAGER="less"
export QT_QPA_PLATFORMTHEME=qt5ct
export GTK_THEME='Dracula'
export GOPATH="$HOME/.local/share/go/"
export MPD_HOST="$HOME/.local/share/mpd/socket"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
