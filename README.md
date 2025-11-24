# dotfiles
config files and scripts i use.
![rizz](img/rice1.png)

Most of my work is in [.local/bin](.local/bin) with a bunch of shell scripts, including the
[script](./local/bin/dt) i use to manage this repo.

Most script dependencies won't be listed, and some scripts/config files depend on other scripts in
this repo.

These dotfiles are not meant to be "installed," but provide examples for how to do many things on a
linux desktop.

## CLI

- neovim with LSP stuff

- lf file manager with ctpv previews

- zsh shell with Luke Smith's config (and changes)

- dash shell for posix scripting

## Desktop

- awesomewm

- sxhkd keybind daemon

- kitty terminal

- dunst notifications

### Media

- pipewire, with (awesome) pure alsa config available

- mpd and ncmpcpp for music

- feh and nsxiv for images

- mpv for videos

### Secrets

- keepassxc for passwords, secret service provider, and TOTP

- keepmenu to access keepass database with dmenu, unlocked with secret storage

- syncthing to sync password vault between devices

## Scripts

See the outdated [README](.local/bin/).

## Services

I use dinit as a user service manager for some things, see [here](.config/dinit.d).

The service manager is started on first login as seen in [.zlogin](.zlogin), and removes itself on
last logout, according to its [boot service](.config/dinit.d/boot). This assumes your login manager
(usually (e)logind) both creates and removes $XDG_RUNTIME_DIR when needed.

The dinit service manager can be installed separately from dinit init, no need to remove systemd.
