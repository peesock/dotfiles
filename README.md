# dotfiles
Config files and scripts i use to create my desktop.

These dotfiles aim to be as cross-compatible as possible for my preferences, meaning all shell scripts are posix sh scripts and i try to reduce dependencies on magic tools or services like a particular init system.
## Tools

### Terminal

- `kitty` terminal for how it renders fonts, especially box drawing characters (see `notcurses-info`). However `alacritty` has all the features i need, and i would still be using it if it had kitty's fonts.
Config is pretty minimal.

- `neovim` config without 14 gorillion plugins (only has 1 gorillion)

- `lf` terminal file manager with `ctpv` previews, basic config with some extra functions

- `zsh` for interactive usage, zshrc and "aliasrc" based off of Luke Smith's dotfiles. basic `starship` prompt. zlogin/out work in progress......
- `dash` used for bare posix scripting

### Desktop

- `sxhkd` hotkey daemon. This is the ultimate interface for almost everything i do on my desktop

- `awesomewm` with minimal config based on the provided example config. Only the actual window management libraries are used; other functionality is passed to other programs. `picom` is used for compositing

- `dunst` notification daemon is pretty good, though i don't do many dunsty things with it

#### Media

- pure ALSA config for general audio needs, has dedicated `mpd` devices. Currently has a bug with underruns... will have to report it

- `mpd` for music, `ncmpcpp` for an mpd client, and `vis`/`cli-visualizer` for real time music visualization

- `mpv` for videos and audio files

- `feh` and `nsxiv` for image viewing, depending on needs...

#### Secrets

- `keepassxc` as a password vault, important document storage, linux secret service provider, and TOTP generator
- `keepmenu` to quickly access passwords from dmenu
- `syncthing` to sync and backup password vault between drives and devices

## Scripts
See the script [README](.local/bin/README.md) for explanation of the more complicated scripts.

Some scripts or config files (like [sxhkdrc](.config/sxhkd/sxhkdrc)) will depend on other scripts to work, so if you need them, either include them or edit the script you need.

Nowadays, some scripts aren't actually scripts, and are compiled binaries in my PATH that i don't include in this repo. As of writing, the programs i want to share are in separate repos on my profile. Namely, [mediapick](https://github.com/peesock/mediapick) for an [lfrc](.config/lf/lfrc) function.

## Services
I am currently experimenting with using `runit` to manage services user-side, independent of init, no root access needed. runit is a little messy in how it does things and i'm considering writing my own basic service manager instead. 

I know systemd exists, and again, i want this to be cross compatible everywhere. and people don't like systemd.
