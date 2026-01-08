#!/usr/bin/env bash

_mas() {
	local cur prev words cword
	local shell_opts="$(shopt -p extglob)"
	shopt -s extglob

	if declare -F _init_completion >/dev/null 2>&1; then
		_init_completion
	else
		COMPREPLY=()
		_comp_get_words cur prev words cword
	fi
	if [[ "${cword}" -eq 1 ]]; then
		local -r ifs_old="${IFS}"
		IFS=$'\n'
		local -a mas_help=($(mas help))
		mas_help=("${mas_help[@]:6:${#mas_help[@]}-7}")
		mas_help=("${mas_help[@]#  }")
		local -a commands=(help)
		for line in "${mas_help[@]}"; do
			if [[ ! "${line}" =~ ^\  ]]; then
				commands+=("${line%%?(,) *}")
			fi
		done
		COMPREPLY=($(compgen -W "${commands[*]}" -- "${cur}"))
		IFS="${ifs_old}"
		eval "${shell_opts}"
		return 0
	fi
	eval "${shell_opts}"
}

complete -F _mas mas
