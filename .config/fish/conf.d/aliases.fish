if status is-interactive
	# auto use sudo
	for cmd in pacman shutdown poweroff reboot
		eval 'alias $cmd "sudo $cmd"'
	end

	# qol
	alias cp 'cp -iv'
	alias mv 'mv -iv'
	alias rm 'rm -vI'
	alias ffmpeg 'ffmpeg -hide_banner'
	alias ffprobe 'ffprobe -hide_banner'
	alias winetricks 'winetricks -q'

	# coloring
	alias ls 'ls --color=auto'
	alias grep 'grep --color=auto'
	alias diff 'diff --color=auto'
	alias ip 'ip -color=auto'

	# shortening
	alias ka 'killall'
	alias g 'git'
	alias sdn 'shutdown -h now'
	alias e '$EDITOR'
	alias P 'pacman'
	alias p 'nice paru'
	alias z 'zathura'

	# special
	alias dash 'rlwrap dash'
	alias lf lfpp
	alias dt 'dt -g $HOME/build/repo/dotfiles'
end
