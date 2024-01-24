# dotfiles
config files and scripts i use.

it's essentially an xorg-based window managered highly scripted and hotkey-oriented minimal desktop.
![rizz](img/rice1.png)

i try to keep script-to-script dependencies minimal, but some tools are just so good that you should get the other script too, like [name](.local/bin/name).
## Tools
### Terminal

- `kitty` for superior font rendering, alacritty otherwise. i would use `foot` on wayland

- `neovim` with fairly simple config

- `lf` terminal file manager with `ctpv` previews

- `zsh` interactive shell, zshrc and aliasrc based off of Luke Smith, basic `starship` prompt

- `dash` shell for posix scripting

### Desktop

- `sxhkd` hotkey daemon. this is the most important part of my UI

- `awesomewm` with minimal config. only the actual window management libs are used; other functionality is passed to other programs like dunst

- `dunst` notification daemon

#### Media

- pure alsa config available, in process of converting that to pipewire

- `mpd` for music, `ncmpcpp` for an mpd client, and `vis`/`cli-visualizer` for real time music visualization

- `mpv` for videos and audio files

- `feh`, `nsxiv` for image viewing, depending on needs

#### Secrets

- `keepassxc` as password vault, important document storage, secret service provider, and TOTP generator
- `keepmenu` to quickly access passwords from dmenu
- `syncthing` to sync and backup password vault between drives and devices

## Scripts
see the script [README](.local/bin/README.md) for script READMEs.

some scripts or config files (like [ffconv](.local/bin/ffconv)) will depend on other scripts to work, so if you need them, either include them or edit the script you need.

these days i write some scripts in C so they don't take days to complete and can properly parse strings, whose binaries are depended on by other dotfiles. they can be found in separate github repos.

## Services
i use a `runit` init system which forced me to learn a little about how runit works, and now i depend on it to manage a bunch of services (managed background processes) on my system. see [here](.local/var/run).

i wouldn't usually include init things in dotfiles because that's a root task, but runit makes no distinction between root and normal user, allowing for user services independent of init system. systemdeezers, openarcers, dinit fans and s6 enjoyers can all use these services if you install runit.
