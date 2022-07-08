# Author: github.com/chillpert

# Vim mode
bindkey -v

# open at home
cd ~/

# Fix for delete key
tput smkx

# Leave TTY as vanilla as possible
if [[ -o login ]] ; then
    return
fi

# Youtube aliases
alias yt='ytfzf --detach -s -S --subs=1 --sort -l --silent'
alias yt-mp3='yt-dlp --extract-audio --audio-format mp3'

# Basic Unix commands aliases
alias ls='ls --group-directories-first -F --color'
alias cdp='f(){ cd "$@"; ls; }; f'
alias grep='grep --color=auto'
alias rm='rm -i'
alias df='df -h'
alias updategrub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias mkdir='mkdir -pv'
alias c='clear'
alias clip='xclip -selection c'

# Git commands aliases
alias gs='git status'
alias gb='git branch'
alias gd='git diff'
alias gf='git fetch'
alias gc='git commit'
alias ga='git add'
alias gl='git log -a --graph --decorate --oneline'
alias gr='git reset'

# For dotfiles
config() {
	pacman -Qqe > .packages
	/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"
}

# FZF everything
of() {
	cd ~/
	fzf | xargs xdg-open
	cd -
}

# Allow multi-select by default
alias fzf="fzf -m"
alias fzfp="fzf --preview='less {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"

alias nv="nvim"
alias vim="nvim"

# Package manager aliases
alias paru-S="paru -Slq | fzf --multi --preview 'cat <(paru -Si {1}) <(paru -Fl {1} | awk \"{print \$2}\")' | xargs -ro paru -S"
alias paru-R="paru -Qq | fzf --multi --preview 'paru -Qi {1}' | xargs -ro paru -Rns"
alias paru-Re="paru -Qeq | fzf --multi --preview 'paru -Qi {1}' | xargs -ro paru -Rns"
alias paru-Q="paru -Qeq | fzf --multi --preview 'paru -Qi {1}'"
alias paru-O="paru -Rns $(paru -Qtdq)"

# Application aliases
alias vpnc='sudo protonvpn c -f'
alias vpnd='sudo protonvpn d'
alias pm='pulsemixer'

# Expand ue4cli
ue() {
	ue4cli=$HOME/.local/bin/ue4
	projects_path=$HOME/Repos
	engine_path=$($ue4cli root)

	if [[ "$1" == "engine" ]]; then
		cd $engine_path
	elif [[ "$1" == "rebuild" ]]; then
		$ue4cli clean
		$ue4cli build 
		if [[ "$2" == "run" ]]; then
			$ue4cli run
		fi
	elif [[ "$1" == "build" ]]; then
		if [[ "${@: -1}" == "run" ]]; then
			length="$(($# - 2))" # Get length without last param because of 'run'
			$ue4cli build ${@:2:$length}
			$ue4cli run
		else
			shift 1
			$ue4cli build "$@"
		fi
	elif [[ "$1" == "gen" ]]; then
		$ue4cli gen
		project=${PWD##*/}
		ln -s ".vscode/compileCommands_${project}.json" compile_commands.json	
		# @TODO: Rewrite 'fixCompileCommands' in bash (I lost the source file)
	    $projects_path/fixCompileCommands .
	elif [[ "$1" == "ctags" ]]; then
		echo "Generating ctags database in current directory ..."
		ctags -R Source
		echo "Generation completed."
	else
		$ue4cli "$@"
	fi
}

alias ue4='echo Please use ue instead.'
alias ue5='echo Please use ue instead.'

file_manager=lf

# Personal aliases
alias guitar='$file_manager /mnt/data/backups/Documents/Tabs'
alias games='$file_manager /mnt/data/SteamLibrary/steamapps/common'

# Make mounting in terminal fast!
mntusb() {
	cd ~/
	mkdir usb
	sudo mount /dev/sdb1 usb
	$file_manager ~/usb
	echo "Do not forget to run umntusb afterwards!"
}

umntusb() {
	cd ~/
	sudo umount usb
	rm -rf usb
}

mntphone() {
	cd ~/
	mkdir phone
	go-mtpfs phone &
	$file_manager ~/phone
	echo "Do not forget to run umntphone afterwards!"
}

umntphone() {
	cd ~/
	umount phone
	rm -rf phone
}

# Navigation (by Derek Taylor)
up () {
    local d=""
    local limit="$1"

    # Default to limit of 1
    if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
        limit=1
    fi

    for ((i=1;i<=limit;i++)); do
        d="../$d"
    done

    # perform cd. Show error if cd fails
    if ! cd "$d"; then
    	echo "Couldn't go up $limit dirs.";
    fi
}

# Extract common file formats (by Derek Taylor)
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

function extract {
	if [ -z "$1" ]; then
        # Display usage if no parameters given
       	echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
       	echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    else
       	for n in "$@"
       	do
       	  	if [ -f "$n" ] ; then
       	  	    case "${n%,}" in
       	  	      	*.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
						tar xvf "$n" ;;
       	  	      	*.lzma) 
						unlzma ./"$n" ;;
       	  	      	*.bz2) 
						bunzip2 ./"$n" ;;
       	  	      	*.cbr|*.rar) 
						unrar x -ad ./"$n" ;;
       	  	      	*.gz) 
						gunzip ./"$n" ;;
       	  	      	*.cbz|*.epub|*.zip) 
						unzip ./"$n" ;;
       	  	      	*.z) 
						uncompress ./"$n" ;;
       	  	      	*.7z|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
       	  	      	    7z x ./"$n" ;;
       	  	      	*.xz)        
						unxz ./"$n" ;;
       	  	      	*.exe)
				       cabextract ./"$n" ;;
       	  	      	*.cpio)      
						cpio -id < ./"$n" ;;
       	  	      	*)
       	  	      		echo "extract: '$n' - unknown archive method"
       	  	      	    return 1
       	  	      	    ;;
       	  			esac
       	  	else
       	  	    	echo "'$n' - file does not exist"
       	  	    	return 1
       		fi
		done
	fi
}

IFS=$SAVEIFS

# Reduce prompt padding on right side
ZLE_RPROMPT_INDENT=0

# Unreal Engine loading time fix
export GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2

# Executables in home
export PATH=$PATH:~/.local/bin

# Add cargo bins to path
export PATH=$PATH:~/.cargo/bin

# Set VIM as default editor
export EDITOR=nvim

# XDG directories
export XDG_DATA_HOME=~/.local/share
export XDG_STATE_HOME=~/.local/state
export XDG_CONFIG_HOME=~/.config
export XDG_DESKTOP_DIR=~/Desktop
export XDG_DOCUMENTS_DIR=~/Documents
export XDG_DOWNLOAD_DIR=~/Downloads
export XDG_MUSIC_DIR=~/Music
export XDG_PICTURES_DIR=~/Pictures
export XDG_PUBLICSHARE_DIR=~/Public
export XDG_TEMPLATES_DIR=~/Templates
export XDG_VIDEOS_DIR=~/Videos

# Misc
export HOSTNAME=arch

# Fix left and right arrow keys
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Fix delete keys
bindkey "^[[3~" delete-char

# Enable autocompletion
autoload -Uz compinit
compinit

# Prompt theme
source ~/.zsh_theme

# Autocompletion with an arrow-key driven interface
zstyle ':completion:*' menu select

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# History
SAVEHIST=2000  
HISTSIZE=2000
HISTFILE=~/.zsh_history

# IBus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# FZF
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Disable filthy caps lock! (requires xorg-setxkbmap)
setxkbmap -option ctrl:nocaps

# Fix for ICU UE5 mismatch
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
