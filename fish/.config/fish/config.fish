source /usr/share/cachyos-fish-config/cachyos-config.fish

export PATH="$PATH:$HOME/.local/bin:$HOME/.pesde/bin"
# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

starship init fish | source
