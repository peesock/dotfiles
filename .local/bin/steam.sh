#!/bin/sh
exec bwrap.sh -preset browser -net -exec --bind-try 'printf %s\\0 ~/.steam ~/.local/share/Steam /var/cache/ldconfig /etc/group /etc/ld.so.cache /etc/ld.so.conf /tmp' -- steam
