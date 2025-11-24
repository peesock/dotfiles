#!/bin/sh
. ./config/deluged.conf
exec bwrap.sh -noshare -net -exec --bind-try 'printf "$HOME/%s\0" '"$folders" -- deluged -d
