#compdef mas
_mas() {
  local ret=1

  _arguments -C \
    '1: :__mas_subcommands' \
    '*::arg:->args' && ret=0

  case "$state" in
    args)
      case ${words[1]} in
        help)
          _arguments -C \
            '1:: :__mas_subcommands' \
            && ret=0
          ;;
        home|info|open|vendor)
          _arguments -C \
            '1:availableIDs:__mas_list_installed_ids' \
            && ret=0
          ;;
        install)
          _arguments -C \
            '--force[Force reinstall]' \
            '*:availableIDs:' \
            && ret=0
          ;;
        purchase)
          _arguments -C \
            '*:availableIDs:' \
            && ret=0
          ;;
        lucky)
          _arguments -C \
            '--force[Force reinstall]' \
            '1:name:__mas_list_available_names' \
            && ret=0
          ;;
        reset)
          _arguments -C \
            '--debug[Enable debug mode]' \
            && ret=0
          ;;
        search)
          _arguments -C \
            '--price[Show price of found apps]' \
            '1:name:__mas_list_available_names' \
            && ret=0
          ;;
        signin)
          _arguments -C \
            '--dialog[Complete login with graphical dialog]' \
            '1:AppleID:' \
            '2::password:' \
            && ret=0
          ;;
        uninstall)
          _arguments -C \
            '--dry-run[Dry run]' \
            '1:installedIDs:__mas_list_installed_ids' \
            && ret=0
          ;;
        upgrade)
          _arguments -C \
            '*:app:__mas_list_outdated' \
            && ret=0
          ;;
        account|list|outdated|signout|version)
          ret=0
          ;;
        *)
          (( ret )) && _message 'No more arguments'
          ;;
      esac
      ;;
  esac

  return $ret
}

__mas_subcommands() {
  local -a commands=(
    'account:Prints the primary account Apple ID'
    'help:Display general or command-specific help'
    'home:Opens MAS Preview app page in a browser'
    'info:Display app information from the Mac App Store'
    'install:Install from the Mac App Store'
    'list:Lists apps from the Mac App Store which are currently installed'
    'lucky:Install the first result from the Mac App Store'
    'open:Opens app page in AppStore.app'
    'outdated:Lists pending updates from the Mac App Store'
    'purchase:Purchase and download free apps from the Mac App Store'
    'reset:Resets the Mac App Store'
    'search:Search for apps from the Mac App Store'
    'signin:Sign in to the Mac App Store'
    'signout:Sign out of the Mac App Store'
    'uninstall:Uninstall app installed from the Mac App Store'
    'upgrade:Upgrade outdated apps from the Mac App Store'
    "vendor:Opens vendor's app page in a browser"
    'version:Print version number'
  )

  _describe -t commands 'command' commands "$@"
}

__mas_list_available_names() {
  _alternative \
    'searchedNames:apps:__mas_search_names' \
    'installedNames:apps:__mas_list_installed_names'
}

# Autocomplete for the names returned by searching for the current word
__mas_search_names() {
  # Don't search if no query has been entered
  [[ -z "${(Q)words[-1]}" ]] && return

  local -a searchNames=("${(f)"$(__mas_filter_names "$(mas search ${(Q)words[-1]} 2>/dev/null)")"}")
  _describe -t searchNames 'search' searchNames "$@"
}

# Autocomplete for the names of installed apps
__mas_list_installed_names() {
  local -a installedNames=("${(f)"$(__mas_filter_names "$(mas list 2>/dev/null)")"}")
  _describe -t installedNames 'installed' installedNames "$@"
}

# Autocomplete for the ids of installed apps
__mas_list_installed_ids() {
  local -A installedApps=("${(f)"$(__mas_filter_descriptive_ids "$(mas list 2>/dev/null)")"}")
  local -a installedIDs=("${(f)"$(printf '%s:%s\n' "${(@kv)installedApps}")"}")
  _describe -t installedIDs 'installed' installedIDs "$@"
}

# Autocomplete for the ids or names of installed apps
__mas_list_outdated() {
  local -A unfilteredOutdated=(
    "${(f)"$(__mas_filter_descriptive_ids "$(mas outdated 2>/dev/null)")"}"
  )

  # Exclude apps which have already been stated
  local -a previousApps=(${(Q@)words:1})
  local -a outdated=()

  for id name in ${(kv)unfilteredOutdated}; do
    local -a searchValues=( "$id" "$name" )
    [[ ${#previousApps:*searchValues} == 0 ]] && outdated+=( "$id:$name" "$name" )
  done

  _describe -t outdated 'outdated' outdated "$@"
}

# Extract app names
__mas_filter_names() {
  local -A apps=("${(f)$(__mas_filter_descriptive_ids "$1")}")
  printf "${(F)apps}"
}

# Extract app ids as an alternating, new-line seperated list of id and name, designed to be used to create an associative array.
__mas_filter_descriptive_ids() {
  printf ${(QF)${(*fqqq)"$(__mas_isolate_id_and_name "$1")"}/ ##/\\n}
}

# Remove leading spaces and the trailing version from the list of apps returned by mas
__mas_isolate_id_and_name() {
  printf ${(*F)${${(*@)${(f)1}%% ##\([^(]##}//:/\\:}## ##}
}

if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
  _mas "$@"
else
  compdef _mas 'mas'
fi
