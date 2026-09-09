source /usr/share/cachyos-fish-config/cachyos-config.fish

export PATH="$PATH:$HOME/.local/bin:$HOME/.pesde/bin"
# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

starship init fish | source

# pnpm
set -gx PNPM_HOME "/home/jerry/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
