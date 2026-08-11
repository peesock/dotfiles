function sudo
	if functions -q $argv[1]
		set cmd "command sudo fish -c \"$argv\""
		eval $cmd
	else
		command sudo $argv
	end
end
