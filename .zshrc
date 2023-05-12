#  Author: github.com/chillpert

# Vim mode
bindkey -v

# open at home
cd ~/

# Fix for delete key
tput smkx

alias sx='startx'

# Leave TTY as vanilla as possible
if [[ -o login ]] ; then
    return
fi

# Youtube aliases
alias yt='ytfzf --detach --subs=1 --sort -l -c youtube-subscriptions'
alias yt-mp3='yt-dlp --extract-audio --audio-format mp3'
alias yt-mp4='yt-dlp -S res,ext:mp4:m4a --recode mp4'

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
alias gch='git checkout'
alias gcp='git cherry-pick'
alias ga='git add'
alias gl='git log -30 -a --graph --decorate --oneline'
alias gr='git reset'
alias gp='git pull'
alias gwr='git worktree remove'
alias gwl='git worktree list'
alias gwp='git worktree prune'

alias stats='~/.scripts/bar/drive_status.sh && ~/.scripts/bar/cpu_monitor.sh && ~/.scripts/bar/gpu_monitor.sh'

# Automated worktree creation and initialization for UE projects
gwa() {
    git worktree add $1 $2
    cp ~/Documents/clang-flags.txt $1
    cd $1
    git submodule update --init --recursive
    ue gen
    ue build
    cd -
}

# For dotfiles
config() {
	pacman -Qqe > ~/.packages
	/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}
alias conf="config"

alias vim="nvim"
alias nv="nvim"
alias n='nvim'
alias nvc="cd ~/.config/nvim/ && nvim"
alias nvimc="cd ~/.config/nvim/ && nvim"

# Package manager aliases
alias paru-S="paru -Slq | fzf --multi --preview 'cat <(paru -Si {1}) <(paru -Fl {1} | awk \"{print \$2}\")' | xargs -ro paru -S"
alias paru-R="paru -Qq | fzf --multi --preview 'paru -Qi {1}' | xargs -ro paru -Rns"
alias paru-Re="paru -Qeq | fzf --multi --preview 'paru -Qi {1}' | xargs -ro paru -Rns"
alias paru-Q="paru -Qeq | fzf --multi --preview 'paru -Qi {1}'"
alias paru-O="paru -Rns $(paru -Qtdq)"
alias cu='checkupdates'

# Application aliases
alias vpnc='protonvpn-cli c -f'
alias vpnd='protonvpn-cli d'
alias pm='pulsemixer'
alias nf='neofetch'

export UE_PATH="/mnt/data/unrealengine"

# Expand ue4cli
ue() {
	ue4cli=$HOME/.local/bin/ue4
	engine_path=$($ue4cli root)

    # cd to ue location
	if [[ "$1" == "engine" ]]; then
		cd $engine_path/Engine/Source
    elif [[ "$1" == "build" ]]; then
        $ue4cli build
        # if [ $? -eq 0 ]; then
        #     notify-send --hint="int:success:1" --app-name="UE" "none" "Compiled ${PWD##*/}"
        #
        # else
        #     notify-send --hint="int:success:0" --app-name="UE" "none" "Failed to compile ${PWD##*/}"
        #     return 1
        # fi
    # Run project files generation, create a symlink for the compile database and fix-up the compile database
	elif [[ "$1" == "gen" ]]; then
		$ue4cli gen
		project=${PWD##*/}
        rm -f compile_commands.json
		ln -s ".vscode/compileCommands_Default.json" compile_commands.json	

        # For UE 5.1
        replace_string="clang++\"\,\n\t\t\t\"@$(pwd)/clang-flags.txt\"\,"
        sed -i -e "s,$engine_path\(.*\)clang++\"\,,$replace_string,g" compile_commands.json
        
        # For UE 4/5.0.3
        # replace_string="clang++ @'$(pwd)/clang-flags.txt'"
        # sed -i -e "s,$engine_path\(.*\)clang++,$replace_string,g" compile_commands.json
    # Generate ctags for project
	elif [[ "$1" == "ctags" ]]; then
        echo "Generating ctags database for unreal engine and this project"
        ctags -R --c++-kinds=+p --fields=+iaS --extras=+q --languages=C++ "$engine_path/Engine/Source" Source
        echo "Generation completed."
    # Pass through all other commands to ue4
	else
		$ue4cli "$@"
	fi
}

# Even faster UE commands
alias ucr='ue clean && ue build'
alias ur='ue build && ue run'

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

function compress {
    if [ -z "$2" ]; then
        echo "Usage: compress <path/file_name> <path/out_file_name>"
    else
        ffmpeg -i "$1" -vcodec libx264 -crf 28 "$2"
    fi
}

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

# Set default editor
export EDITOR=nvim

# Set default terminal emulator
export TERMINAL=alacritty

# Fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

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
source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh
source /usr/share/zsh/plugins/forgit-git/forgit.plugin.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# History
SAVEHIST=2000  
HISTSIZE=2000
HISTFILE=~/.zsh_history

# FZF
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Use silver_searcher by default
if type ag &> /dev/null; then
    export FZF_DEFAULT_COMMAND='ag -p ~/.gitignore -g ""'
fi

# Use rg by default
export FZF_ALT_C_COMMAND="rg --files --null | xargs -0 dirname | uniq | sort -u"

# FZF everything
of() {
	cd ~/
	fzf | xargs xdg-open
	cd -
}

# Disable filthy caps lock! (requires xorg-setxkbmap)
setxkbmap -option ctrl:nocaps

# Fix for ICU UE5 mismatch
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Icons for LF
export LF_ICONS="`cat $HOME/.config/lf/LF_ICONS`"

# Suspend process toggle (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fancy-ctrl-z)
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z
