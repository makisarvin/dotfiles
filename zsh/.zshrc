#
# Individual commands to measure load time
# time zsh -lic exit
# for non-login interactive shell
# time zsh -ic exit

# uncomment to measure load time 
zmodload zsh/zprof

# ========================
# History
# ========================

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

# XDG dirs are not created by anything else; without these zsh silently
# fails to read/write the history file and the completion cache.
mkdir -p "${HISTFILE:h}" "$XDG_CACHE_HOME/zsh"

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# =======================
# Shell Behaviour
# =======================

setopt AUTOCD # move to directories without cd
setopt NOBEEP
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1

# =========================================================
# Completion
# =========================================================

# Load completion system
autoload -Uz compinit

# Initialize completion with cached metadata file.
# Skip the compaudit security scan unless the dump is missing/stale (>24h),
# since compaudit stats every dir in $fpath and dominates shell startup time.
ZCOMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"
if [[ -n "$ZCOMPDUMP"(#qN.mh+24) ]]; then
  compinit -d "$ZCOMPDUMP"
else
  compinit -C -d "$ZCOMPDUMP"
fi

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # lowercase input matches upper and lower

# =========================================================
# Fuzzy finder
# =========================================================

# macOS / Homebrew (Apple Silicon)
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

# Arch
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
fi

# =========================================================
# Modular Config Files
# =========================================================

# fzf configuration
source "$ZSH_CONFIG_HOME/fzf.zsh"

# Aliases
source "$ZSH_CONFIG_HOME/aliases.zsh"

# Custom keybindings
source "$ZSH_CONFIG_HOME/bindings.zsh"

# Plugins and plugin manager
source "$ZSH_CONFIG_HOME/plugins.zsh"

# Widgets
source "$ZSH_CONFIG_HOME/widgets.zsh"

# Prompt/theme
source "$ZSH_CONFIG_HOME/prompt.zsh"

# ===================================
# AWS Certificates
# ===================================
export AWS_CA_BUNDLE=$HOMEBREW_PREFIX/etc/ca-certificates/cert.pem
export AWS_DEFAULT_PROFILE=default

# ===================================
# PATH
# ===================================

# Python
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
# export PATH="/opt/anaconda3/bin:$PATH"

# Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby@3.2/bin:$PATH"

# JAVA
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Pesde
export PATH="$PATH:/Users/makis/.pesde/bin"

# .local/bin
export PATH="$PATH:/Users/makis/.local/bin"


# uncomment to measure load time
zprof
