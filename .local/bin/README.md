# apock
Screen locker wrapper.

Dependencies:
- alock - https://github.com/arkq/alock
- xss-lock
- $TERMINAL / alacritty
- cli-visualizer

`5wock` to lock, `5wock warn` to sleep for XORG_SCREENSAVER_CYCLE seconds and hang.

If you have that music visualizer, it will be displayed.



# basicrop
Basic cropping script.

Dependencies:
- feh
- hacksaw
- sxhkd
- graphicsmagick
- bc

These deps can be easily replaced with other programs. `hacksaw` can be replaced with `slop`, `gm convert` (`graphicsmagick`) with `convert` (imagemagick), or `feh` with `nsxiv` (with some argument tweaking). It's a very simple script, with the most complex part being some multiplication.

## usage
Set screen dimensions in the file (default is 1920x1080).

Usage: `basicrop [INFILE] [OUTFILE]`. If OUTFILE isn't specified, INFILE will always be overwritten.
- 'c' to crop
- 'u' to undo
- 'A' to toggle anti-aliasing
- 'Escape' or 'q' to quit
- 'Return' to save file
- 'shift' + 'Return' to overwrite file

Because there's no way to communicate the image's location to the script, you cannot zoom in or translate. sorry!!!!

## how
`basicrop input output` will open `input` in fullscreen mode. With your screen dimensions, this acts like a ruler by constraining the sides of your image to the sides of the screen. Cropping will simply take the dimensions of the screen captured in an area, and scale it up or down to the size of the image. Those dimensions are trimmed if needed, and then fed to graphicsmagick to produce `output`.

sxhkd is used to temporarily steal a set of keys from your keyboard to use for the script. I'm sure there's a way to do it with more simple X tools, but if i wanted to make this more of a PITA then i would've make a Real image editor in C, with zooming and translating and drawing and such. But i didn't feel like it

## why
I had all the tools on my system, and a brand new screenshot script in need of an editor. Actually, this used to be embedded into that screenshot script until i decided to split it up.

In the future I'll make a real editor.



# maptoggle.sh
toggles an X window between mapped and unmapped, ie, visible/invisible, using custom window properties to distinguish windows. Uses xdotool and xprop.


## usage
maptoggle.sh ID "command args..." [options]
`ID` is added to a new X window property (named with `$0`), which can be found with xprop.

`command` is only used to start the program, and does not need to be included in future runs of this tool, if the window isn't killed.

`-echo` will echo the window id to stdout when making the window visible, for use in scripts like when enabling persistent floating state or window sizes.

Return code 2 means the program was just started for the first time.

## examples
Most window properties are in the EWMH spec that your WM most likely supports. For these, you can use wmctrl to control them. Some properties, like floating/tiling status, are not in the spec, and depend on your specific window manager. For awesomewm, this works:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo)
awesome-client "local c = nil ; for _, c2 in ipairs(client.get()) do ; if c2.window == $winid then ; c = c2 ; break ; end ; end ; if not c then return end ; c.floating = true"
```
which sucks but I don't care.

For fullscreen in any EWMH window manager:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo); wmctrl -ir $winid -b add,fullscreen
```

Place a 50% sized window in the middle of the screen:
```sh
winid=$(maptoggle.sh "magic id" $TERMINAL -echo); xdotool windowmove $winid 25% 25% ; xdotool windowsize $winid 50% 50%
```

Example of an awesomewm music player toggle:
```sh
wid=$(maptoggle.sh "musically" "$TERMINAL -e ncmpcpp" -echo)
[ -n $wid ] &&
(awesome-client "local c = nil ; for _, c2 in ipairs(client.get()) do ; if c2.window == $wid then ; c = c2 ; break ; end ; end ; if not c then return end ; c.floating = true"
xdotool windowmove $wid 25% 25%
xdotool windowsize $wid 50% 50%)
unset wid
```



# ocrgrab
small desktop barcode and text grabber

dependencies:
- `zbar`
- `tesseract` (and the lang models you want)
- `hacksaw` and `shotgun` or edit for another tool

crops a section of the screen, notifies if a barcode, text, or nothing was captured, and sends to clipboard.



# screenshot
Minimal screenshot script for X

dependencies:
- `shotgun`
- `hacksaw`
- `basicrop` - optional cropping component

`shotgun` and `hacksaw` can be replaced with `maim` and `slop`. 
Replacing the editor is harder, but still straightforward. `basicrop` shrimply takes an input and output file, so if another editor can do something like that, then no problem.

## usage
First set `$fotoDir` to a default dir for your screenshots, and change `$foto` for a different default filename.
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
Crop a screenshot to out.png without copying to clipboard:

`screenshot crop -o out.png file`

Take a screenshot to out.png without the clipboard while cropping:

`screenshot -o out.png file crop`

Remove clipboard copying and take a cropped screenshot to out.png:

`screenshot file crop -o out.png`

Take a full screenshot to /tmp:

`screenshot temp`

Edit:

`screenshot edit` to save in `$fotoDir`, or `screenshot temp edit` to keep the result in /tmp