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
alias ls='ls -F --group-directories-first --color'
alias grep='grep --color=auto'
alias rm='rm -i'
alias df='df -h'
alias c='clear'

# Git commands aliases
alias gs='git status'
alias gsw='git switch'
alias gb='git branch'
alias gd='git diff'
alias gf='git fetch'
alias gc='git commit'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias grs='git diff --name-only | fzf --multi --preview "git diff --color {}" | xargs -I {} git restore {}'
alias ga='git add'
alias gl='git log -30 -a --graph --decorate --oneline'
alias gr='git reset'
alias gp='git pull'
alias gwt='git worktree'
alias grb='git rebase'

alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Package manager aliases
alias paru-S="paru -Slq | fzf --multi --preview 'cat <(paru -Si {1}) <(paru -Fl {1} | awk \"{print \$2}\")' | xargs -ro paru -S"
alias paru-R="paru -Qq | fzf --multi --preview 'paru -Qi {1}' | xargs -ro paru -Rns"
alias paru-Re="paru -Qeq | fzf --multi --preview 'paru -Qi {1}' | xargs -ro paru -Rns"
alias paru-Q="paru -Qeq | fzf --multi --preview 'paru -Qi {1}'"
alias cu='checkupdates'

# Application aliases
alias vpnc='protonvpn-cli c -f'
alias vpnd='protonvpn-cli d'
alias pm='pulsemixer'
alias nf='neofetch'

export UE_PATH="/var/home/n30/Repos/unrealengine/"

# Expand ue4cli
ue() {
	ue4cli=$HOME/.local/bin/ue4
	engine_path=$($ue4cli root)

    # cd to ue location
	if [[ "$1" == "engine" ]]; then
		cd $engine_path/Engine/Source
    elif [[ "$1" == "build" ]]; then
        $ue4cli build
    elif [[ "$1" == "gen" ]]; then
	$ue4cli gen
	project=${PWD##*/}
        rm -f compile_commands.json
		ln -s ".vscode/compileCommands_Default.json" compile_commands.json	

        replace_string="clang++\"\,\n\t\t\t\"@$(pwd)/clang-flags.txt\"\,"
        sed -i -e "s,$engine_path\(.*\)clang++\"\,,$replace_string,g" compile_commands.json
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
alias ucr='ue clean && ue build && ue run'
alias ur='ue build && ue run'

alias ue4='echo Please use ue instead.'
alias ue5='echo Please use ue instead.'

file_manager=lf

# Personal aliases
alias guitar='$file_manager /mnt/data/backups/Documents/Tabs'
alias games='$file_manager /mnt/data/SteamLibrary/steamapps/common'

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

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

function compress {
    if [ -z "$2" ]; then
        echo "Usage: compress <path/file_name> <path/out_file_name>"
    else
        ffmpeg -i "$1" -vcodec libx264 -crf 28 "$2"
    fi
}

# Extract common file formats (by Derek Taylor)
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

# Zsh Plugins

# Install Antidote
if ! [ -d ~/.antidote/ ]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
fi

source ~/.antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# History
export SAVEHIST=2000  
export HISTSIZE=2000
export HISTFILE=~/.zsh_history
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# FZF
if ! source /usr/share/fzf/shell/key-bindings.zsh; then
    echo "Please install fzf"
fi

# Use silver_searcher by default
if type ag &> /dev/null; then
    export FZF_DEFAULT_COMMAND='ag -p ~/.gitignore -g ""'
fi

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Use rg by default
export FZF_ALT_C_COMMAND="rg --files --null | xargs -0 dirname | uniq | sort -u"

# Fix for ICU UE5 mismatch
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Icons for LF
export LF_ICONS="`cat $HOME/.config/lf/LF_ICONS`"

# Helpers for flashing QMK keyboard
alias qmk-flash-left="qmk flash -kb ferris/sweep_choc_mbuk -km chillpert -bl uf2-split-left -e CONVERT_TO=elite_pi"
alias qmk-flash-right="qmk flash -kb ferris/sweep_choc_mbuk -km chillpert -bl uf2-split-left -e CONVERT_TO=elite_pi"
alias qmk-compile="qmk compile -kb ferris/sweep_choc_mbuk -km chillpert"
alias qmk-chillpert="cd ~/qmk_firmware/keyboards/ferris/keymaps/chillpert/ && nvim ."
