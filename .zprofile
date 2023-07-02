#!/bin/sh
# vim: ft=sh

# custom environment variables
export QT_QPA_PLATFORMTHEME=qt5ct
export TERMINAL=kitty
export BROWSER=firefox
export SCREENSHOTS=$HOME/pics/screenshots
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$HOME/.local/bin:$PATH
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export PAGER="less"
export GTK_THEME= 'Dracula' # 'Sweet-Dark-v40'
export GOPATH="$HOME/.local/share/go/"
export DBUS_SESSION_BUS_ADDRESS="autolaunch:" # don't ask me how dbus works
# export GTK_USE_PORTAL=1
export MPD_HOST="$HOME/.local/share/mpd/socket"
export NBRC_PATH="$HOME/.config/nb/nbrc"
export NB_DIR="$HOME/.config/nb/"

## silly luke LFmojis
#export LF_ICONS="di=📁:\
#fi=📃:\
#tw=🤝:\
#ow=📂:\
#ln=⛓:\
#or=❌:\
#ex=🎯:\
#*.txt=✍:\
#*.mom=✍:\
#*.me=✍:\
#*.ms=✍:\
#*.png=🖼:\
#*.webp=🖼:\
#*.ico=🖼:\
#*.jpg=📸:\
#*.jpe=📸:\
#*.jpeg=📸:\
#*.gif=🖼:\
#*.svg=🗺:\
#*.tif=🖼:\
#*.tiff=🖼:\
#*.xcf=🖌:\
#*.html=🌎:\
#*.xml=📰:\
#*.gpg=🔒:\
#*.css=🎨:\
#*.pdf=📚:\
#*.djvu=📚:\
#*.epub=📚:\
#*.csv=📓:\
#*.xlsx=📓:\
#*.tex=📜:\
#*.md=📘:\
#*.r=📊:\
#*.R=📊:\
#*.rmd=📊:\
#*.Rmd=📊:\
#*.m=📊:\
#*.mp3=🎵:\
#*.opus=🎵:\
#*.ogg=🎵:\
#*.m4a=🎵:\
#*.flac=🎼:\
#*.wav=🎼:\
#*.mkv=🎥:\
#*.mp4=🎥:\
#*.webm=🎥:\
#*.mpeg=🎥:\
#*.avi=🎥:\
#*.mov=🎥:\
#*.mpg=🎥:\
#*.wmv=🎥:\
#*.m4b=🎥:\
#*.flv=🎥:\
#*.zip=📦:\
#*.rar=📦:\
#*.7z=📦:\
#*.tar.gz=📦:\
#*.z64=🎮:\
#*.v64=🎮:\
#*.n64=🎮:\
#*.gba=🎮:\
#*.nes=🎮:\
#*.gdi=🎮:\
#*.1=ℹ:\
#*.nfo=ℹ:\
#*.info=ℹ:\
#*.log=📙:\
#*.iso=📀:\
#*.img=📀:\
#*.bib=🎓:\
#*.ged=👪:\
#*.part=💔:\
#*.torrent=🔽:\
#*.jar=♨:\
#*.java=♨:\
#"
