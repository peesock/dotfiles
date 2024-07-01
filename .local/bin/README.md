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
image cropping script.

dependencies:
- feh
- hacksaw/grim
- sxhkd
- graphicsmagick
- bc

hacksaw and graphicsmagick are easily replacable by slop and imagemagick.

despite using an X hotkey daemon, it does actually work through Xwayland because the image viewer feh is also xwayland, so pressing keys on the feh window will also be registered by sxhkd.

## usage
`basicrop infile outfile` if outfile isn't specified, infile will always be overwritten.
- 'c' to crop
- 'u' to undo
- 'A' to toggle anti-aliasing
- 'Esc' or 'q' to quit
- 'Return' to save file
- 'Shift' + 'Return' to overwrite file

because there's no way to communicate the image's location to the script, you cannot zoom in or translate.

### how
`basicrop input output` will open `input` in fullscreen mode. this way, your screen dimensions act as a ruler, and we know where to crop based on hacksaw output and image dimensions.

sxhkd is how we take keyboard input, which sucks, but i don't care.


# memory-sync
mostly for moving firefox's profile to memory for speed and hard disk life.

## usage
`memory-sync [options] uniqueName dirToCopy [ [-p $pid | binary] | [ram | disk | auto] ]`
the flags are confusing -- i might rewrite argument handling later.
the script has comments to explain all flags.

`memory-sync firefox ~/.mozilla/firefox` will sync firefox profile to either ram or to disk, depending on whether it's already been synced to ram.

`memory-sync -D -e -u 30m firefox ~/.mozilla/firefox "firefox"` will sync firefox profile to ram once every 30 minutes, and then sync and exit on firefox exit.



# dt
dotfile git management script. it uses hardlinks instead of symlinks to manage the repo, following the argument of [this blogpost](https://port19.xyz/tech/hardlinks/).

## usage
- add          run link and git add on all arguments
- dotpath      returns either the git (default) or working (-R) path of specified argument
- g            runs git with modified options and file paths to change the dot repo
- help         helps
- init         run git init on git dir
- link         recursively hardlink all arguments to git dir (requires GNU cp)
- link -R      runs link in reverse, restoring your dotfiles from git. use -f to force
- mv           mv + git mv, only 2 args (i need to rewrite this stupid program in C)
- rm           recursively remove *both* existing hardlinks (and folders) of argument
- run          run arguments as if you were in the git repo (if outside, defaults to top)
- unlinked     list files in git dir that don't exist in working dir

the default dot directory and working directory are ~/.dotfiles and ~. they can be changed with the `-g` and `-w` flags. to simplify this, you could use aliases or edit the defaults directly.

## examples
normal usage:
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
adding git files without cluttering your home directory:
`$ dt g add ~/.dotfiles/README.md`

Also see my ~/.zshrc to add git autocomplete.



# maptoggle.sh
toggles an X window between mapped and unmapped, ie, visible/invisible (not minimized). Uses xwininfo and xdotool.

## usage
`maptoggle.sh [ID | command] [command] [options]`

`ID` identifies a specific window to look for

`command` is only used to start the program, and does not need to be included in future runs of this tool, if the window isn't killed.

`-echo` will echo the window id to stdout when mapping the window, for use in scripts to enable persistent floating state or window geometry.

## examples
EWMH-compliant window managers (almost all of them) will let you change window geometry after mapping. some properties, like floating/tiling status, are not in the spec, and depend on your specific window manager. for awesomeWM:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo)
awesome-client "local c = nil ; for _, c2 in ipairs(client.get()) do ; if c2.window == $winid then ; c = c2 ; break ; end ; end ; if not c then return end ; c.floating = true"
```

fullscreen:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo); wmctrl -ir $winid -b add,fullscreen
```

place a 50% x 50% sized window in the middle of the screen:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo); xdotool windowmove $winid 25% 25% ; xdotool windowsize $winid 50% 50%
```

awesomewm music player toggle:
```sh
wid=$(maptoggle.sh "musically" "$TERMINAL -e ncmpcpp" -echo)
[ -n $wid ] &&
(awesome-client "local c = nil ; for _, c2 in ipairs(client.get()) do ; if c2.window == $wid then ; c = c2 ; break ; end ; end ; if not c then return end ; c.floating = true"
xdotool windowmove $wid 25% 25%
xdotool windowsize $wid 50% 50%)
unset wid
```



# name
utility for naming files, that i need to rewrite in C

## usage
`name [-d DELIM] FUNCTION [ARG] [FILENAME]...`
-d sets input and output deliminator.

functions:
- rename - renames files based on `image.png, image-1.png, image-2.png` syntax
- reextend EXT - replace or add new extensions
- base - return filename with no extension
- ext - return only extension

arguments can also be piped in:
```
$ ls
2021-12-24_21-06.png
20220731-021309_473.png

$ ls | name rename
2021-12-24_21-06-1.png
20220731-021309_473-1.png
```



# ocrgrab
small desktop barcode and text grabber

dependencies:
- zbar
- tesseract (and the lang models you want)
- hacksaw/slurp
- shotgun/grim

crops a section of the screen, notifies if a barcode, text, or nothing was captured, and sends to clipboard.



# screenshot
Xorg screenshot script

dependencies:
- shotgun/grim
- hacksaw/slurp
- basicrop - optional, for cropping

## usage
set `$fotoDir` in the script to a default dir for your screenshots.
```
Usage: screenshot [options]

Options:
-o [OUTFILE]    specify an output file
crop            use crop/window select mode
temp            send file to /tmp for temporary storage and clipboarding
file            file-only, don't save image to clipboard
edit            edit the most recently-taken screenshot
```

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



# volume
volume ctrl util for alsa and pulse/pipewire

dependencies:
- amixer
- pactl

## usage
`volume [a | p] [vol | mute] [Direction Num] [Name] [Card]`

## examples
decrease soundcard volume by 5%:
`volume a vol - 5 Master hw:PCH`
increase pulseaudio "Global" device volume by 5%:
`volume p vol + 5 Global`
toggle mute "Global":
`volume p mute Global`
