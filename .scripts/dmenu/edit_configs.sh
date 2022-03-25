#!/bin/bash

declare options=("zshrc
zsh_history
picom
polybar
vim
i3
ytfzf
xinitrc
desktop-files
mpv
cmus
ncspot
gtk
pulse
ranger
scripts")

choice=$(echo -e "${options[@]}" | dmenu -nf '#FFFFFF' -sb '#af87ff' -sf '#FFFFFF' -nb '#262626' -i -fn 'VL PGothic-11.5' -m 0 -w 0 -p 'Configs: ')

case "$choice" in
	quit)
		echo "Program terminated." && exit 1
	;;
	zshrc)
		choice="$HOME/.zshrc"
	;;
	zsh_history)
		choice="$HOME/.zsh_history"
	;;
	picom)
		choice="$HOME/.config/picom/picom.conf"
	;;
	polybar)
		choice="$HOME/.config/polybar"
	;;
	vim)
		choice="$HOME/.vimrc"
	;;
	i3)
		choice="$HOME/.config/i3"
	;;
	ytfzf)
		choice="$HOME/.config/ytfzf/subscriptions"
	;;
	xinitrc)
		choice="$HOME/.xinitrc"
	;;
	desktop-files)
		choice="$HOME/.local/share/applications"
	;;
	mpv)
		choice="$HOME/.config/mpv/mpv.conf"
	;;
	cmus)
		choice="$HOME/.config/cmus"
	;;
	ncspot)
		choice="$HOME/.config/ncspot/config.toml"
	;;
	gtk)
		choice="$HOME/.config/gtk-3.0/settings.ini"
	;;
	pulse)
		choice="$HOME/.config/pulse"
	;;
	ranger)
		choice="$HOME/.config/ranger"
	;;
	scripts)
		choice="$HOME/.local/bin/scripts"
	;;
	*)
		exit 1
	;;
esac

st -e vim "$choice"

