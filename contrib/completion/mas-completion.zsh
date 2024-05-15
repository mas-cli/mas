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
            '1:availableIDs:__mas_list_available_ids' \
            && ret=0
          ;;
        install)
          _arguments -C \
            '--force[Force reinstall]' \
            '*:availableIDs:__mas_list_available_ids' \
            && ret=0
          ;;
        purchase)
          _arguments -C \
            '*:availableIDs:__mas_list_available_ids' \
            && ret=0
          ;;
        lucky)
          _arguments -C \
            '--force[Force reinstall]' \
            '1:name:__mas_list_available' \
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
            '1:name:__mas_list_available' \
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

__mas_list_available_ids() {
  _alternative \
    'searchedIDs:apps:__mas_search_ids' \
    'installedIDs:apps:__mas_list_installed_ids'
}

__mas_list_available() {
  _alternative \
    'ids:apps:__mas_list_available_ids' \
    'searchedNames:apps:__mas_search_names' \
    'installedNames:apps:__mas_list_installed_names'
}

__mas_search_ids() {
  [[ -z "$words[-1]" ]] && return

  local -a searchIDs=(${(f)"$(__mas_filter_ids "$(mas search $words[-1] 2>/dev/null)")"})
  _describe -t searchIDs 'search' searchIDs "$@"
}

__mas_search_names() {
  [[ -z "$words[-1]" ]] && return

  local -a searchNames=(${(f)"$(__mas_filter_names "$(mas search $words[-1] 2>/dev/null)")"})
  _describe -t searchNames 'search' searchNames "$@"
}

__mas_list_outdated() {
  local -a outdated=(${(f)"$(__mas_filter_ids "$(mas outdated 2>/dev/null)")"} ${(f)"$(__mas_filter_names "$(mas outdated 2>/dev/null)")"})
  _describe -t outdated 'outdated' outdated "$@"
}

__mas_list_installed_ids() {
  local -a installedIDs=(${(f)"$(__mas_filter_ids "$(mas list 2>/dev/null)")"})
  _describe -t installedIDs 'installed' installedIDs "$@"
}

__mas_list_installed_names() {
  local -a installedNames=(${(f)"$(__mas_filter_names "$(mas list 2>/dev/null)")"})
  _describe -t installedNames 'installed' installedNames "$@"
}

__mas_filter_names() {
  __mas_strip_price "$1" | sed -nEe 's/^[[:space:]]*[0-9\-]+[[:space:]]+//pg'
}

__mas_filter_ids() {
  __mas_strip_price "$1" | sed -nEe 's/^[[:space:]]*([0-9\-]+)[[:space:]]*(.*)/\1:\2/pg'
}

__mas_strip_price() {
  echo "$1" | sed -nEe 's/[[:space:]]+\(.*\).*$//pg' | sed 's/:/\\:/g'
}

if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
  _mas "$@"
else
  compdef _mas 'mas'
fi
