set -g fish_transient_prompt 1
functions -q fish_mode_prompt_old || functions -c fish_mode_prompt fish_mode_prompt_old

function fish_mode_prompt
	if contains -- --final-rendering $argv
	else
		fish_mode_prompt_old
	end
end

function fish_prompt --description 'Write out the prompt'
	set -l last_status $status
	echo

	echo -n "$(set_color --bold $fish_color_user)╭─$USER$(set_color --reset)@"
	echo -n "$(set_color --bold $fish_color_host)$(prompt_hostname)$(set_color --reset) in "
	set_color $fish_color_cwd
	echo -n (prompt_pwd)
	set_color --reset
	if test $CMD_DURATION -gt 0
		set -l time "$(math --scale=0 $CMD_DURATION % 1000)ms"
		echo -n " took "
		if [ $CMD_DURATION -ge 1000 ]
			set time "$(math --scale=0 $CMD_DURATION / 1000 % 60)s$time"
			[ $CMD_DURATION -ge 60000 ] && {
				set time "$(math --scale=0 $CMD_DURATION / 60000 % 60)m$time"
			}
			[ $CMD_DURATION -ge 3600000 ] && {
				set time "$(math --scale=0 $CMD_DURATION / 3600000)h$time"
			}
		end
		set_color --bold bryellow
		echo -n $time
		set_color --reset
	end

	#set -q __fish_git_prompt_showdirtystate
	#or set -g __fish_git_prompt_showdirtystate 1
	#set -q __fish_git_prompt_showuntrackedfiles
	#or set -g __fish_git_prompt_showuntrackedfiles 1
	#set -q __fish_git_prompt_showcolorhints
	#or set -g __fish_git_prompt_showcolorhints 1
	#set -q __fish_git_prompt_color_untrackedfiles
	#or set -g __fish_git_prompt_color_untrackedfiles yellow
	#set -q __fish_git_prompt_char_untrackedfiles
	#or set -g __fish_git_prompt_char_untrackedfiles '?'
	#set -q __fish_git_prompt_color_invalidstate
	#or set -g __fish_git_prompt_color_invalidstate red
	#set -q __fish_git_prompt_char_invalidstate
	#or set -g __fish_git_prompt_char_invalidstate '!'
	#set -q __fish_git_prompt_color_dirtystate
	#or set -g __fish_git_prompt_color_dirtystate blue
	#set -q __fish_git_prompt_char_dirtystate
	#or set -g __fish_git_prompt_char_dirtystate '*'
	#set -q __fish_git_prompt_char_stagedstate
	#or set -g __fish_git_prompt_char_stagedstate '✚'
	#set -q __fish_git_prompt_color_cleanstate
	#or set -g __fish_git_prompt_color_cleanstate green
	#set -q __fish_git_prompt_char_cleanstate
	#or set -g __fish_git_prompt_char_cleanstate '✓'
	#set -q __fish_git_prompt_color_stagedstate
	#or set -g __fish_git_prompt_color_stagedstate yellow
	#set -q __fish_git_prompt_color_branch_dirty
	#or set -g __fish_git_prompt_color_branch_dirty red
	#set -q __fish_git_prompt_color_branch_staged
	#or set -g __fish_git_prompt_color_branch_staged yellow
	#set -q __fish_git_prompt_color_branch
	#or set -g __fish_git_prompt_color_branch green
	#set -q __fish_git_prompt_char_stateseparator
	#or set -g __fish_git_prompt_char_stateseparator '⚡'
	#fish_vcs_prompt '|%s'

	echo

	set -l end
	if test $last_status -eq 0
		set end '╰─λ '
	else if test $last_status -eq 127
		set end '╰🔍 × '
	else if test $last_status -gt 128
		set end "╰⚡ $(math $last_status - 128) × "
	else if test $last_status -ge 1
		set end '╰🔴 × '
	end

	set_color $fish_color_user
	echo -n $end
	set_color --reset
end
