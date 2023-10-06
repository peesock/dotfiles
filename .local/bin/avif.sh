#!/usr/bin/env sh
programName=$(basename "$0")
usage(){
	echo "\
usage:
1: $programName [OPTIONS] SOURCE DEST
2: $programName [OPTIONS] SOURCE... DIRECTORY
3: $programName [OPTIONS] SOURCE...

1: Convert SOURCE to DEST with file type given by extension.
2: Convert SOURCE(s) to DIRECTORY, auto rename files
3: Convert SOURCE(s) to auto renamed files

options:
-h            print help
-t ext        specify filetype by extension, eg. jpg
-f            no autonaming; will overwrite files
-k            keep extensions as-is
-o \"args\"     insert ffmpeg options

examples:

    $programName farter.avif
to make farter.png, or if farter.png exists, farter-1.png

    $programName -t -k jpg farter.webm baghdad.imagizer
to make a jpeg image out of a webm video

    $programName *.webp pics/
to convert all files ending in .webp to png and place DEST(s) in pics/ folder

    $programName -t avif -k -f *.png
to secretly overwrite all your pngs into avifs and keep .png extension
"
}
renamer(){
	n=1
	out=$1
	while true; do
		# echo $out >&2
		[ -f "$out" ] || break
		# SED MASTER
		out="$(echo "$out" | sed "s/\(.*\)-$((n - 1))\(\..*\)\|\(.*\)\(\..*\)\|\(.*\)-$((n - 1))\$\|\(.*\)/\1\3\5\6-$n\2\4/")"
		n=$((n + 1))
	done
	echo "$out"
	unset out n
}
extensioner(){
	echo "$1" | sed "s/\(.*\)\..*\|\$/\1.$2/"
}

type=png
while true; do
	[ "$1" = "-t" ] && type=$2 && shift 2 && continue
	[ "$1" = "-f" ] && force=true && shift && continue
	[ "$1" = "-k" ] && keep=true && shift && continue
	[ "$1" = "-o" ] && convOpts=$2 && shift 2 && continue
	[ "$1" = "-h" ] && usage && exit
	break
done

last=$(eval "echo \${$#}")
evaller(){
	outfile="$infile"
}
if [ -d "$last" ]; then
	evaller(){
		outfile="$last/$infile"
	}
fi

converter(){
	echo
	tmp=$(mktemp -u).$type
	ffmpeg -hide_banner -i "$infile" $convOpts "$tmp"
	mv -v "$tmp" "$outfile"
}

while [ $# -gt 0 ]; do
	infile=$1
	[ -f "$infile" ] || {
		echo "'$infile' not a file" >&2
		shift
		continue
	}

	evaller
	[ $keep ] ||
		outfile="$(extensioner "$outfile" "$type")"
	[ $force ] ||
		outfile="$(renamer "$outfile")"
	echo "in: '$infile'"
	echo "out: '$outfile'"
	converter
	shift
done
