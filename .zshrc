#  Author: github.com/chillpert

# -------------------------------------------------------------------------------------------
# -------------------------------------Functions---------------------------------------------
# -------------------------------------------------------------------------------------------

# For dotfiles
config() {
	/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

# On WSL2 file system speed with /mnt/c/ is slow; this is a workaround
function git() {
    git.exe "$@"
}

function setup_aliases() {
    # Youtube aliases
    alias yt-mp3='yt-dlp --extract-audio --audio-format mp3'
    alias yt-mp4='yt-dlp -S res,ext:mp4:m4a --recode mp4'
    
    # Basic Unix commands aliases
    alias ls='ls --group-directories-first -F --color'
    alias cdp='f(){ cd "$@"; ls; }; f'
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
}

function setup_exports() {
    # Executables in home
    export PATH=$PATH:~/.local/bin
    
    # Add cargo bins to path
    export PATH=$PATH:~/.cargo/bin
    
    # Set default editor
    export EDITOR=nvim
}

function setup_zsh() {
    # Enable autocompletion
    autoload -Uz compinit
    compinit

    # Prompt theme
    source ~/.zsh_theme

    # History
    SAVEHIST=2000  
    HISTSIZE=2000
    HISTFILE=~/.zsh_history

    # Install Antidote
    if ! [ -d ~/.antidote/ ]; then
        git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
    fi
    
    # Load Antidote plugins
    source ~/.antidote/antidote.zsh
    antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins
    
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    
    # Autocompletion with an arrow-key driven interface
    zstyle ':completion:*' menu select
}

function setup_fzf() {
    # FZF
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh

    # Use silver_searcher by default
    if type ag &> /dev/null; then
        export FZF_DEFAULT_COMMAND='ag -p ~/.gitignore -g ""'
    fi

    # Use rg by default
    # @todo find a working command
    #export FZF_ALT_C_COMMAND="rg --files --null | xargs -0 dirname | uniq | sort -u"
    #@todo find a working command
    #export FZF_ALT_C_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
    #export FZF_ALT_C_COMMAND='ag --hidden --ignore --gitignore -G ./'
    
    # FZF everything
    of() {
    	cd ~/
    	fzf | xargs xdg-open
    	cd -
    }
}

function setup_inputs() {
    # Fix for delete key
    tput smkx
    
    # Fix left and right arrow keys
    bindkey "^[[1;5C" forward-word
    bindkey "^[[1;5D" backward-word
    
    # Fix delete keys
    bindkey "^[[3~" delete-char

    # Vim mode
    bindkey -v
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

# --------------------------------------------------------------------------------------------
# -------------------------------------Start here---------------------------------------------
# --------------------------------------------------------------------------------------------

cd ~/

setup_aliases
setup_exports
setup_inputs
setup_zsh
setup_fzf

# Icons for LF
export LF_ICONS="`cat $HOME/.config/lf/LF_ICONS`"
