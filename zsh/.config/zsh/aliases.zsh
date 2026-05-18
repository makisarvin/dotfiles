# better ls
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias tree='eza --tree --icons'

# reuse ls completitions
compdef eza=ls

# better cat
alias cat='bat'

# core
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# navigation
cd() {
  if [[ "$1" == "..." ]]; then
    builtin cd ../..
  elif [[ "$1" == "...." ]]; then
    builtin cd ../../..
  elif [[ "$1" == "....." ]]; then
    builtin cd ../../../..
  else
    builtin cd "$@"
  fi
}

# editor
alias vim='nvim'

# obsidian
note() {
  obsidian daily:append content="$*"
}

