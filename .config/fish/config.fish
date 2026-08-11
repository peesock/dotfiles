if status is-login
{
	# environment
	set -gx DBUS_SESSION_BUS_ADDRESS unix:path=$XDG_RUNTIME_DIR/dbus.sock
	set -gx BROWSER firefox.sh
	set -gx SCREENSHOTS ~/pics/screenshots
	set -gx EDITOR nvim
	set -gx XDG_CONFIG_HOME ~/.config
	set -pgx PATH ~/.local/bin
	set -gx MANPAGER 'nvim +Man!'
	set -gx PAGER less
	set -gx QT_QPA_PLATFORMTHEME qt5ct
	set -gx GTK_THEME Dracula
	set -gx GOPATH "$HOME/.local/share/go"
	set -gx MPD_HOST "$HOME/.local/share/mpd/socket"
	set -gx GTK_IM_MODULE fcitx
	set -gx QT_IM_MODULE fcitx
	set -gx XMODIFIERS @im=fcitx

	# user service management
	if not string length -q -- $XDG_RUNTIME_DIR
		echo XDG_RUNTIME_DIR not set. user services won\'t start.
		return
	end

	if not test -e "$XDG_RUNTIME_DIR/.login"
		if not test -d $XDG_RUNTIME_DIR
			echo XDG_RUNTIME_DIR doesn\'t exist. user services disabled.
			return
		end
		echo first login!
		touch "$XDG_RUNTIME_DIR/.login"
		setsid -f dinit -q -u >/dev/null 2>&1 0>&1
	end
}
end

if status is-interactive
	functions -e fish_greeting
	set -g fish_key_bindings fish_vi_key_bindings
	set -g fish_function_path /usr/share/fish/vendor_functions.d "$XDG_CONFIG_HOME/fish/functions"
	set -g fish_complete_path /usr/share/fish/vendor_completions.d "$XDG_CONFIG_HOME/fish/completions" \
		"$__fish_cache_dir/generated_completions"
end
