# Add git completion for aliases
if [ -f /usr/share/bash-completion/completions/git ]; then
  . /usr/share/bash-completion/completions/git
fi

# Basic file/directory navigation
alias ..='cd ..'
alias ~='cd ~'
alias repos='cd ~/Documents/personal/repositories'

# Git shortcuts
alias g='git'
__git_complete g __git_main
alias gs='git status'
__git_complete gs _git_status
alias ga='git add'
__git_complete ga _git_add
alias gc='git commit'
__git_complete gc _git_commit
alias gp='git push'
__git_complete gp _git_push
alias gpl='git pull'
__git_complete gpl _git_pull
alias grb='git rebase'
__git_complete grb _git_rebase
alias gco='git checkout'
__git_complete gco _git_checkout
alias gl='git log --oneline --graph --decorate'
__git_complete gl _git_log
alias gd='git diff'
__git_complete gd _git_diff
alias gsh='git stash'
__git_complete gsh _git_stash

ge() {
  git add -u
  git diff --staged
  git commit -m "$1"
  git push $2
}
gz() {
  git reset --soft "$1"
  git restore --staged *
}

# Quality of life
alias reload='source ~/.bashrc'
alias h='history'

# Anki
alias anki='export ANKI_WAYLAND=1; anki'
