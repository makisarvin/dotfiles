# ~/.config/zsh/.zshenv

# ---------- XDG base directories ----------
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export ZSH_CONFIG_HOME="$XDG_CONFIG_HOME/zsh"
# --------- Editor -------------------------
# Default editor
export EDITOR="nvim"
export VISUAL="nvim"

# -------- Starship ------------------------
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"

# ---------- PATH ----------
# Personal binaries/scripts
export PATH="$HOME/.local/bin:$PATH"
