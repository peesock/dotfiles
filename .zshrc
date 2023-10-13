# Luke's config for the Zoomer Shell

# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments

# starship prompt
eval "$(starship init zsh)"
function set_win_title(){
	echo -ne "\033]0; $USER@$HOST:${PWD/$HOME/~} \007"
}
precmd_functions+=(set_win_title)

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"

# add autocomplete for special aliases
_dt () {
	cwd=$PWD
	dir=$(dt -g "$HOME/.dotfiles" dotpath -- "$cwd") ||
		dir=$HOME/.dotfiles
	cmp(){
		[ -d "$dir" ] && exist=true
		mkdir -p "$dir"
		cd "$dir"
		_complete
		[ $exist ] || rmdir --ignore-fail-on-non-empty -p "$dir"
		cd "$cwd"
	}
	for ((i=0, lim=3; i < lim; i++)); do
		case "${words[i]}" in
			-w)
				[ $i -eq $CURRENT ] && break
				lim=$((lim + 2))
				;;
			-g)
				[ $i -eq $CURRENT ] && break
				dir=$(dt -g "$(eval "echo ${words[i+1]}")" dotpath -- "$cwd") ||
					dir=$(eval "echo ${words[i+1]}")
				lim=$((lim + 2))
				;;
			g)
				# idk how to run _git properly
				words[i]="git"
				shift $((i - 1)) words
				(( CURRENT -= (i-1) ))
				cmp
				return
				;;
			run) # note that `dt run dt ...` will cd incorrectly :(
				shift $i words
				(( CURRENT -= i ))
				cmp
				return
				;;
		esac
	done
	cd "$cwd"
	_files
}
compdef _dt dt

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
case $KEYMAP in
	vicmd) echo -ne '\e[1 q';;      # block
	viins|main) echo -ne '\e[5 q';; # beam
esac
}
zle -N zle-keymap-select
zle-line-init() {
zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
	tmp="$(mktemp -uq)"
	trap 'rm -f $tmp >/dev/null 2>&1' HUP INT QUIT TERM PWR EXIT
	lf -last-dir-path="$tmp" "$@"
	if [ -f "$tmp" ]; then
		dir="$(cat "$tmp")"
		[ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
	fi
}
bindkey -s '^o' '^ulfcd\n'

bindkey -s '^a' '^uqalc\n'

bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

bindkey '^[[P' delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

# Use fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Use autosuggestion
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load syntax highlighting; should be last.
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null

# Load nvm
# source /usr/share/nvm/init-nvm.sh
