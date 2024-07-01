# dotfiles
config files and scripts i use.
![rizz](img/rice1.png)

most of my work is in [.local/bin](.local/bin) with a bunch of shell scripts.

most dependencies probably won't be listed, but crazy rare ones will be. a few scripts (and config files) depend on other scripts, so like all dotfiles, skim through the content before copy+pasting.

## CLI

- kitty terminal

- neovim, LSP stuff included

- lf TUI file manager with ctpv previews

- zsh interactive shell in vim mode with starship prompt

- dash for posix scripting

## Desktop

- sxhkd keybind daemon, very important

- awesomewm with minimal config

- dunst notifications

### media

- pure alsa config available, in process of converting that to pipewire

- mpd and ncmpcpp for music

- feh and nsxiv for images

- mpv

### secrets

- keepassxc for passwords, document storage, secret service provider, and TOTP

- keepmenu to access keepass database from dmenu, auto unlocked with secret storage

- syncthing to sync password vault between devices, among other things

## Scripts
see the [README](.local/bin/).

not everything i write is in there; some of it is disorganized in other non-dot directories and written in C.

## Services
i use runit as a service manager (and init) for some things. see [here](.local/var/run/runit)

the beauty of runit or anything else that isn't systemd is you don't need the matching init system to run its services, as user or as root. just install runit and start it up [somehow](.zlogin).
