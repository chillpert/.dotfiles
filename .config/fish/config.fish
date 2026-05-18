source /usr/share/cachyos-fish-config/cachyos-config.fish

alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

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

alias c='clear'

function compress --description "Compress video with ffmpeg"
      if test (count $argv) -lt 2
          echo "Usage: compress <path/file_name> <path/out_file_name>"
      else
          ffmpeg -i $argv[1] -vcodec libx264 -crf 28 $argv[2]
      end
end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
