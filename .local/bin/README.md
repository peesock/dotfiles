# apock
screen locker wrapper.

dependencies:
- alock - https://github.com/arkq/alock
- xss-lock

fancy dependencies:
- $TERMINAL / alacritty by default
- cli-visualizer
- xscreensaver screensavers, ie everything in `/usr/lib/xscreensaver`

## usage
use `apock` to lock from cli
use `apock xss` and `apock warn` with xss-lock, like
```
xss-lock -n 'apock warn' -- apock xss'
```
specify a screensaver function:
```
xss-lock -n 'apock warn' -- apock xss visualizer &
...
apock xscreensaver
```


# basicrop
image cropping script.

dependencies:
- feh
- hacksaw
- sxhkd
- graphicsmagick
- bc

hacksaw and graphicsmagick are easily replacable by slop and imagemagick.

## usage
`basicrop infile outfile` if outfile isn't specified, infile will always be overwritten.
- 'c' to crop
- 'u' to undo
- 'A' to toggle anti-aliasing
- 'Escape' or 'q' to quit
- 'Return' to save file
- 'shift' + 'Return' to overwrite file

because there's no way to communicate the image's location to the script, you cannot zoom in or translate.

### how
`basicrop input output` will open `input` in fullscreen mode. this way, your screen dimensions act as a ruler, and we know where to crop based on hacksaw output.

sxhkd is how we take keyboard input, which sucks, but i don't care.


# browser-sync
moves firefox profile to memory for speed and disk life.

## usage
`browser-sync [-d] [-e] browser-name browser-binary profile-dir`
- -d - runs it as a daemon, constantly syncing
- -e - as a daemon, exit when browser-binary exits

`browser-sync ff-dev firefox ~/.mozilla/firefox` will sync firefox profile to ram one time.

`browser-sync -d -e ff-dev firefox ~/.mozilla/firefox` will sync firefox profile to ram once every 30 minutes, and then sync and exit on firefox exit.



# dt
dotfile git management script. it uses hardlinks instead of symlinks to manage the repo, following the argument of [this blogpost](https://port19.xyz/tech/hardlinks/).

## usage
- init - run git init on git dir
- link - recursively hardlink all arguments to git dir (requires GNU cp)
- link -R - runs link in reverse, restoring your dotfiles from git. use -f to force
- add - run link and git add on all arguments
- mv - mv + git mv, only 2 args (i need to rewrite this stupid program in C)
- rm - recursively remove *both* existing hardlinks (and folders) of argument
- run - run arguments as if you were in the git repo (if outside, defaults to top)
- g - runs git with modified options and file paths to change the dot repo
- help - helps
- dotpath - returns either the git (default) or working (-R) path of specified argument

the default dot directory and working directory are ~/.dotfiles and ~. they can be changed with the `-g` and `-w` flags. to simplify this, you could use aliases or edit the defaults directly.

note to self: missing function to detect when home files are removed externally (not through `dt rm`).

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
toggles an X window between mapped and unmapped, ie, visible/invisible, using custom window properties to distinguish windows. Uses xdotool and xprop.

## usage
`maptoggle.sh ID "command args..." [options]`

`ID` is added to a new X window property (named with `$0`), which can be found with xprop.

`command` is only used to start the program, and does not need to be included in future runs of this tool, if the window isn't killed.

`-echo` will echo the window id to stdout when making the window visible, for use in scripts like when enabling persistent floating state or window sizes.

return code 2 means the program was just started for the first time.

## examples
most window properties are in the EWMH spec that your WM most likely supports. for these, you can use wmctrl to control them. some properties, like floating/tiling status, are not in the spec, and depend on your specific window manager. for awesomeWM:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo)
awesome-client "local c = nil ; for _, c2 in ipairs(client.get()) do ; if c2.window == $winid then ; c = c2 ; break ; end ; end ; if not c then return end ; c.floating = true"
```

fullscreen in any EWMH window manager:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo); wmctrl -ir $winid -b add,fullscreen
```

place a 50% x 50% sized window in the middle of the screen:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo); xdotool windowmove $winid 25% 25% ; xdotool windowsize $winid 50% 50%
```

example of an awesomewm music player toggle:
```sh
wid=$(maptoggle.sh "musically" "$TERMINAL -e ncmpcpp" -echo)
[ -n $wid ] &&
(awesome-client "local c = nil ; for _, c2 in ipairs(client.get()) do ; if c2.window == $wid then ; c = c2 ; break ; end ; end ; if not c then return end ; c.floating = true"
xdotool windowmove $wid 25% 25%
xdotool windowsize $wid 50% 50%)
unset wid
```



# name
utility for naming files.

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
- hacksaw
- shotgun

crops a section of the screen, notifies if a barcode, text, or nothing was captured, and sends to clipboard.



# screenshot
Xorg screenshot script

dependencies:
- shotgun
- hacksaw
- xclip
- basicrop - optional, for cropping

shotgun and hacksaw could be replaced with maim and slop.
replacing the editor is harder, but it's just a shell script.

## usage
first set `$fotoDir` in the script to a default dir for your screenshots.
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
