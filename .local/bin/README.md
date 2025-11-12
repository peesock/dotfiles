# apock
screen locker wrapper for Xorg

dependencies:
- alock - https://github.com/arkq/alock
- xset

extra dependencies:
- xwininfo
- $TERMINAL / alacritty by default
- cli-visualizer
- xscreensaver library, IE everything in `/usr/lib/xscreensaver`

## usage
use `apock` to lock from cli
use `apock warn` with xss-lock, like
```
xss-lock -n 'apock warn' -- apock
```
specify a screensaver function:
```
xss-lock -n 'apock warn' -- apock visualizer &
...
apock xscreensaver
```


# basicrop
Image cropping script.

Dependencies:
- feh
- hacksaw/grim
- sxhkd
- graphicsmagick
- bc

Despite using an X hotkey daemon, it does actually work through Xwayland because the image viewer
feh is also xwayland, so pressing keys on the feh window will also be registered by sxhkd.

## usage
`basicrop infile [outfile]` if outfile isn't specified, infile always be overwritten.
- 'c' to crop
- 'u' to undo
- 'A' to toggle anti-aliasing
- 'Esc' or 'q' to quit
- 'Return' to save file
- 'Shift' + 'Return' to overwrite file

Because there's no way to communicate the image's location to the script, you cannot zoom in or
otherwise transform the view of the image and crop as expected.


# bwrap.sh
Wrapper for the bubblewrap sandboxing tool.

Dependencies:
- bubblewrap

My quick and dirty attempt to make a general application sandboxer, à la flatpak, without
containers/package management.

It is only tested on my particular Nvidia + Intel machine on Arch/Artix linux, and file locations
for their corresponding things change, so there are no guarantees that your program will run inside
an otherwise functional sandbox without manual intervention.

## usage
```
bwrap.sh [-options...] [--bwrap-options...] [--] program [arguments...]
```
- -echo: do not run the command; echo it
- -noshare: wrapper version of --unshare-all
- -share "ARG1 \[ARG2...]": re-share namespaces removed by -noshare
- -env "\[ARG1...]": remove environment except for vars listed in ARG...
- -root: pretend to be root user
- -wine: add paths for wine usage
- -proton: add paths for (standalone) proton usage
- -display: add access to current Xorg/wayland sockets
- -exec OPT CMD: expand \0-delimited output of CMD to `OPT line line` per-line
- -pass NUM ARGS...: say the next NUM ARGS are to be added to the bwrap command line
- -data OPT PATH DATA: create a file at PATH containing DATA according to OPT={--file, --bind-data,
  --ro-bind-data}
- -net: add networking
- -gpu: add gpu devices
- -cpu: add cpu devices
- -audio: expose audio
- -theme: add theming files
- -dbus: expose dbus interface
- -path: add all $PATH locations
- -preset PRESET: set a group of options where PRESET={browser, game}
- -noreap: do not reap child process group
- -interactive: sets -noreap, makes sandbox less secure but allows TUI applications
- -autobind: bind the dir of the first argument of bwrap.sh that looks like a path
- -cwd: bind cwd

In the future i will attempt to make or steal some kind of library for linux sandboxing file
locations/methods that any application can use, instead of 300 lines of shell.


# dt
Dotfile git management script. Uses hardlinks instead of symlinks to manage the repo, following the
argument of [this blogpost](https://port19.xyz/tech/hardlinks/).

Dependencies:
- GNU cp

## usage
- add: run link and git add on all arguments
- dotpath: returns either the git (default) or working (-R) path of specified argument
- g: runs git with modified options and file paths to change the dot repo
- help: helps
- init: run git init on git dir
- link: recursively hardlink all arguments to git dir (requires GNU cp)
- link -R: runs link in reverse, restoring your dotfiles from git. use -f to force
- mv: mv + git mv, only 2 args (i need to rewrite this stupid program in C)
- rm: recursively remove *both* existing hardlinks (and folders) of argument
- run: run arguments as if you were in the git repo (if outside, defaults to top)
- unlinked: list files in git dir that don't exist in working dir

The default dot directory and working directory are ~/.dotfiles and ~. They can be changed with the
`-g` and `-w` flags. To simplify this, you could use aliases.

## examples
Normal usage:
```
$ dt init
Initialized empty Git repository in /home/user/.dotfiles/.git/

$ dt add .config/alacritty .config/kitty
linking '.config/alacritty' to '/home/user/.dotfiles/.config/alacritty'
linking '.config/kitty' to '/home/user/.dotfiles/.config/kitty'

$ dt g status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
    new file:   .config/alacritty/alacritty.yml
    new file:   .config/kitty/kitty.conf

$ dt g commit -m "my beloved files"
$ dt g rm .config/alacritty
$ dt g commit -m "i hate alacritty"
$ dt rm .config/kitty/kitty.conf
removing '.config/kitty/kitty.conf' and '/home/apoc/.dotfiles/.config/kitty/kitty.conf'
/bin/rm: remove 2 arguments recursively? y

$ dt g commit -m "i HATE kitty"
```

Add git files without cluttering your home directory:
`$ dt g add ~/.dotfiles/README.md`

Also see my [.zshrc](/.zshrc) to add git autocomplete.


# ffconv
Ffmpeg wrapper for batch files and slightly faster common cli usage

Dependencies:
- [name](./name)

## usage
```
1: $programName [OPTIONS] SOURCE DEST
2: $programName [OPTIONS] SOURCE... DIRECTORY
3: $programName [OPTIONS] SOURCE...

1: Convert SOURCE to DEST with file type given by extension.
2: Convert SOURCE(s) to DIRECTORY, auto rename files
3: Convert SOURCE(s) to auto renamed files
```
- -h: print help
- -t EXT: specify filetype by extension, eg. jpg
- -f: no autonaming; will overwrite files
- -k: keep extensions as-is
- -o "ARGS": insert ffmpeg options

# maptoggle.sh
Toggles an X window between mapped and unmapped, ie, visible/invisible (not minimized). Uses xwininfo and xdotool.

## usage
`maptoggle.sh [ID | command] [command] [options]`

`ID` identifies a specific window to look for.

`command` is only used to start the program, and does not need to be included in future runs of this tool, if the window isn't killed.

`-echo` will echo the window id to stdout when mapping the window, for use in scripts to enable persistent floating state or window geometry.

## examples
EWMH-compliant window managers (almost all of them) will let you change window geometry after
mapping. Some properties, like floating/tiling status, are not in the spec, and depend on your
specific window manager. For awesomeWM:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo)
awesome-client "local c = nil ; for _, c2 in ipairs(client.get()) do ; if c2.window == $winid then ; c = c2 ; break ; end ; end ; if not c then return end ; c.floating = true"
```

Fullscreen:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo); wmctrl -ir $winid -b add,fullscreen
```

Place a 50% x 50% sized window in the middle of the screen:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo); xdotool windowmove $winid 25% 25% ; xdotool windowsize $winid 50% 50%
```

Awesomewm music player toggle:
```sh
wid=$(maptoggle.sh "musically" "$TERMINAL -e ncmpcpp" -echo)
[ -n $wid ] &&
(awesome-client "local c = nil ; for _, c2 in ipairs(client.get()) do ; if c2.window == $wid then ; c = c2 ; break ; end ; end ; if not c then return end ; c.floating = true"
xdotool windowmove $wid 25% 25%
xdotool windowsize $wid 50% 50%)
unset wid
```


# memory-sync
Don't use. Last time i tried rewriting it i ended up wiping most of my firefox config.


# killer
Script to kill every process you can as politely (and quickly) as possible.

## usage
```
killer ["nofork"] [OPTION]... [PID]...
"nofork" prevents forking
PID will not be killed
```

- -c: send CONT signal after TERM
- -d: dry run, echos kill commands instead of running them
- -p: also kill parent process, only applicable with nofork
- -t TIME: timeout time. default is 15s
- -u USERS: set users to kill, comma delimited
- -v: invert users to match

## examples
`killer` without root will fork, and kill all processes owned by $USER, except login shells.
'killer -l` will kill login shells after killing everything else.
`killer` as root kills every process owned by every user (including root) except their login shells.
`killer nofork` will prevent forking. this can cause the script to kill a distant parent that it needs to survive, like Xorg hosting the terminal that runs `killer`.


# name
Utility for naming files, that i need to rewrite in C

## usage
```
name [-d DELIM] FUNCTION [ARG] [FILENAME]...
-d sets input and output deliminator.
```
- rename - renames files based on `image.png, image-1.png, image-2.png` syntax
- reextend EXT - replace or add new extensions
- base - return filename with no extension
- ext - return only extension

Arguments can also be piped in:
```
$ ls
2021-12-24_21-06.png
20220731-021309_473.png

$ ls | name rename
2021-12-24_21-06-1.png
20220731-021309_473-1.png
```


# ocrgrab
Desktop barcode and text grabber.

Dependencies:
- zbar
- tesseract (and the lang models you want)
- hacksaw/slurp
- shotgun/grim

crops a section of the screen, notifies if a barcode, text, or nothing was captured, and sends to clipboard.


# screenshot
Xorg/wayland screenshot script

Dependencies:
- shotgun/grim
- hacksaw/slurp
- xclip/wl-clip
- basicrop - optional, for cropping

## usage
set `$fotoDir` in the script to a default dir for your screenshots.
- -o [OUTFILE]: specify an output file
- crop: use crop/window select mode
- temp: send file to /tmp for temporary storage and clipboarding
- file: file-only, don't save image to clipboard
- edit: edit the most recently-taken screenshot

## examples
crop a screenshot to out.png without copying to clipboard:
`screenshot crop -o out.png file`

take a screenshot to out.png without the clipboard while cropping:
`screenshot -o out.png file crop`

remove clipboard copying and take a cropped screenshot to out.png:
`screenshot file crop -o out.png`

take a full screenshot to /tmp:
`screenshot temp`

edit:
`screenshot edit` to save in `$fotoDir`, or `screenshot temp edit` to keep the result in /tmp


# timer
Saves and appends process time in a file.

## usage
```
timer FILE COMMAND [ARGS...]
```
Where FILE contains the elapsed time of COMMAND.


# volume
Volume ctrl util for alsa and pulse/pipewire.

Dependencies:
- amixer
- pactl

## usage
```
volume [a | p] {vol | mute} [DIRECTION NUM] NAME CARD
```

## examples
decrease soundcard volume by 5%:
`volume a vol - 5 Master hw:PCH`
increase pulseaudio "Global" device volume by 5%:
`volume p vol + 5 Global`
toggle mute "Global":
`volume p mute Global`


# vpnapp.sh
Runs or sets up process namespaces to contain a wireguard VPN as well as full access to LAN. Runs
sudo internally.

Dependencies:
- ip (iproute2)
- ping (iputils)
- wg (wireguard-tools)

## usage
```
vpnapp.sh [OPTIONS] {-p PID | COMMAND [ARGS]}
```
- -s PROGRAM: set "sudo" to PROGRAM
- -w PATH: set VPN with wireguard conf file at PATH


# westonscope
Run a command inside of nested weston in kiosk mode.

Dependencies:
- xrandr
- inotify
- weston

## usage
```
westonscope [OPTIONS] COMMAND [ARGS]
```
- -f: make weston fullscreen
- -g WIDTH HEIGHT: set weston geometry
