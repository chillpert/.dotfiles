# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

alias db="distrobox"
alias dev="distrobox enter dev -- zsh"
alias nvim="flatpak run io.neovim.nvim"
alias config='dconf dump / > .config/gnome-settings.bak && /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

function compress {
    if [ -z "$2" ]; then
        echo "Usage: compress <path/file_name> <path/out_file_name>"
    else
        ffmpeg -i "$1" -vcodec libx264 -crf 28 "$2"
    fi
}
