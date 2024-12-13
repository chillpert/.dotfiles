# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export PATH

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi

unset rc

# Basic Unix commands aliases
alias ls='ls -1 -F --group-directories-first --color'
alias grep='grep --color=auto'
alias rm='rm -i'
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
alias gl='git log -30 -a --graph --decorate --oneline'
alias gr='git reset'
alias gp='git pull'
alias gwt='git worktree'
alias grb='git rebase'

# Shortcuts
alias nvimc='cd ~/Repos/chillpert.nvim/ && nvim init.lua'

# Applications
alias yt-mp3='yt-dlp --extract-audio --audio-format mp3'
alias yt-mp4='yt-dlp -S res,ext:mp4:m4a --recode mp4'
alias vim='nvim'

# Custom git add
ga() {
    if [ $# -ne 0 ]; then
        git add "$@"
    else
        git status -s | fzf --ansi \
            --preview-window 'right:60%' \
            --height '80%' \
            --bind='ctrl-/:toggle-preview' \
            --multi \
            --preview='
            file=$(echo {} | cut -c4-)
            case $(echo {} | cut -c1) in
                "?") bat --color=always "$file" ;;
                "D") git show "HEAD:$file" --color=always ;;
                *) git diff --color=always -- "$file" ;;
            esac' | cut -c4- | xargs -I {} git add {}
    fi
}

# Custom git restore
grs() {
    if [ $# -ne 0 ]; then
        git restore "$@"
    else
        git diff --name-only | fzf --multi --preview "git diff --color {}" | xargs -I {} git restore {}
    fi
}

# Ensure git completions work
source ~/git-completion.bash

__git_complete ga _git_add
__git_complete gsw _git_switch
__git_complete gb _git_branch
__git_complete gd _git_diff
__git_complete gf _git_fetch
__git_complete gc _git_commit
__git_complete gco _git_checkout
__git_complete gcp _git_cherry_pick
__git_complete gl _git_log

# Default applications
export EDITOR=nvim

# Desktop utility
function compress {
    if [ -z "$2" ]; then
        echo "Usage: compress <path/file_name> <path/out_file_name>"
    else
        ffmpeg -i "$1" -vcodec libx264 -crf 28 "$2"
    fi
}

# Install chocolatey package manager
if ! command -v choco 2>&1 >/dev/null; then
    winget install choco
fi

# Install fzf
if command -v choco 2>&1 >/dev/null; then
    if ! command -v fzf 2>&1 >/dev/null; then
        choco install fzf
    fi

    if ! command -v npm 2>&1 >/dev/null; then
        choco install nodejs
    fi
fi

if command -v fzf 2>&1 >/dev/null; then
    eval "$(fzf --bash)"
fi

# Install ripgrep
if command -v choco 2>&1 >/dev/null; then
    if ! command -v rg 2>&1 >/dev/null; then
        choco install rg
    fi
fi

if command -v rg 2>&1 >/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden -L --max-depth 3 --follow'
    export FZF_CTRL_T_COMMAND='rg --files --hidden -L --follow'
    # @note Did not work with rg in Git Bash for Windows
    #export FZF_ALT_C_COMMAND='rg --hidden --null -L --max-depth 3 | xargs -0 dirname | sort -u'
    export FZF_ALT_C_COMMAND='find . -mindepth 1 -maxdepth 3 -type d -not -path '*/\.git/*''
fi

# @note Why did ~/ not work here?
if [ ! -e 'C:\Users\chillpert\.ignore' ]; then
    echo "Create '.ignore' file for ripgrep in home directory."
    echo ".git" > '~/.ignore'
fi
