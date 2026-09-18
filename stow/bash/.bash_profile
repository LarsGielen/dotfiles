#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

if command -v uwsm >/dev/null && uwsm check may-start; then
	exec uwsm start hyprland.desktop
fi

if [[ -f ~/.config/shell/profile.sh ]]; then
    . ~/.config/shell/profile.sh
fi
