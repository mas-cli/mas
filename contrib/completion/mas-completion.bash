#!/usr/bin/env bash

_mas() {
  local cur prev words cword
  if declare -F _init_completions >/dev/null 2>&1; then
    _init_completion
  else
    COMPREPLY=()
    _get_comp_words_by_ref cur prev words cword
  fi
  if [[ $cword -eq 1 ]]; then
    COMPREPLY=($(compgen -W "$(mas help | tail +3 | awk '{print $1}')" -- "$cur"))
    return 0
  fi
}

complete -F _mas mas
