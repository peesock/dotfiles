function se
	set cwd (pwd)
	cd ~/.local/bin
	if [ (count $argv) -gt 0 ]
		$EDITOR $argv[1]
	else
		$EDITOR (fzf)
	end
	cd $cwd
end
