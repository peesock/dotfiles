#!/bin/sh
# exec ctpv "$@"
exec unshare -c bwrap --ro-bind /usr/bin /usr/bin --ro-bind /usr/share /usr/share/ --ro-bind /usr/lib /usr/lib --ro-bind /usr/lib32 /usr/lib32 --symlink lib /usr/lib64 --symlink /usr/lib /lib64 --symlink /usr/lib /lib --symlink /usr/bin /bin --symlink /usr/bin /sbin --tmpfs /tmp --tmpfs /run --proc /proc --dev /dev --unshare-all --bind ~/.cache ~/.cache --ro-bind ~/.config ~/.config --dev-bind /dev/shm /dev/shm --ro-bind "$1" "$1" --ro-bind ~/.local/bin/chafa ~/.local/bin/chafa --ro-bind /etc /etc -- ctpv "$@"
