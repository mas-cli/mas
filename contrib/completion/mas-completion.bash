#!/usr/bin/env bash

_mas() {
	local cur prev words cword
	if declare -F _init_completions >/dev/null 2>&1; then
		_init_completion
	else
		COMPREPLY=()
		_get_comp_words_by_ref cur prev words cword
	fi
	if [[ "${cword}" -eq 1 ]]; then
		local -r ifs_old="${IFS}"
		IFS=$'\n'
		local -a mas_help=($(mas help))
		mas_help=("${mas_help[@]:5:${#mas_help[@]}-6}")
		mas_help=("${mas_help[@]#  }")
		local -a commands=(help)
		for line in "${mas_help[@]}"; do
			if [[ ! "${line}" =~ ^\  ]]; then
				commands+=("${line%% *}")
			fi
		done
		COMPREPLY=($(compgen -W "${commands[*]}" -- "${cur}"))
		IFS="${ifs_old}"
		return 0
	fi
}

complete -F _mas mas
