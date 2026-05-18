# =========================================================
# fzf
# =========================================================

export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'  # strip-cwd-prefix removes the leading ./ from results

# Ctrl-T uses fd
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# UI
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
'

export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

# Ctrl+F: file picker excluding hidden files
_fzf_file_no_hidden() {
  local cmd result
  cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  result=$(eval "${cmd:-find . -type f}" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"  # LBUFFER is the text left of the cursor
  zle reset-prompt
}
zle -N _fzf_file_no_hidden

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected extracted_with_perl=0
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases no_glob no_sh_glob no_ksharrays extendedglob 2> /dev/null
  # Ensure the module is loaded if not already, and the required features, such
  # as the associative 'history' array, which maps event numbers to full history
  # lines, are set. Also, make sure Perl is installed for multi-line output.
  if zmodload -F zsh/parameter p:{commands,history} 2>/dev/null && (( ${+commands[perl]} )); then
    selected="$(printf '%s\t%s\000' "${(kv)history[@]}" |
      perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,alt-r:toggle-raw --wrap-sign '\t↳ ' --highlight-line --multi ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} --read0") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
      extracted_with_perl=1
  else
    selected="$(fc -rl 1 | __fzf_exec_awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,alt-r:toggle-raw --wrap-sign '\t↳ ' --highlight-line --multi ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER}") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  fi
  local ret=$?
  local -a cmds
  # Avoid leaking auto assigned values when using backreferences '(#b)'
  local -a mbegin mend match
  if [ -n "$selected" ]; then
    # Heuristic to check if the selected value is from history or a custom query
    if ((( extracted_with_perl )) && [[ $selected == <->$'\t'* ]]) ||
    ((( ! extracted_with_perl )) && [[ $selected == [[:blank:]]#<->(  |\* )* ]]); then
      # Split at newlines
      for line in ${(ps:\n:)selected}; do
        if (( extracted_with_perl )); then
          if [[ $line == (#b)(<->)(#B)$'\t'* ]]; then
            (( ${+history[${match[1]}]} )) && cmds+=("${history[${match[1]}]}")
          fi
        elif [[ $line == [[:blank:]]#(#b)(<->)(#B)(  |\* )* ]]; then
          # Avoid $history array: lags behind 'fc' on foreign commands (*)
          # https://zsh.org/mla/users/2024/msg00692.html
          # Push BUFFER onto stack; fetch and save history entry from BUFFER; restore
          zle .push-line
          zle vi-fetch-history -n ${match[1]}
          (( ${#BUFFER} )) && cmds+=("${BUFFER}")
          BUFFER=""
          zle .get-line
        fi
      done
      if (( ${#cmds[@]} )); then
        # Join by newline after stripping trailing newlines from each command
        BUFFER="${(pj:\n:)${(@)cmds%%$'\n'#}}"
        CURSOR=${#BUFFER}
      fi
    else # selected is a custom query, not from history
      LBUFFER="$selected"
    fi
  fi
  zle reset-prompt
  return $ret
}

if [[ ${FZF_CTRL_R_COMMAND-x} != "" ]]; then
  if [[ -n ${FZF_CTRL_R_COMMAND-} ]]; then
    echo "warning: FZF_CTRL_R_COMMAND is set to a custom command, but custom commands are not yet supported for CTRL-R" >&2
  fi
  zle     -N            fzf-history-widget
  bindkey -M emacs '^R' fzf-history-widget
  bindkey -M vicmd '^R' fzf-history-widget
  bindkey -M viins '^R' fzf-history-widget
fi
