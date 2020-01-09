# fish completions for mas

function __fish_mas_list_available -d "Lists applications available to install from the Mac App Store"
    set query (commandline -ct)
    if set results (command mas search $query 2>/dev/null)
        for res in $results
            echo $res
        end | string trim --left | string replace -r '\s+' '\t'
    end
end

function __fish_mas_list_installed -d "Lists installed applications from the Mac App Store"
    command mas list 2>/dev/null \
    | string replace -r '\s+' '\t'
end

function __fish_mas_outdated_installed -d "Lists outdated installed applications from the Mac App Store"
    command mas outdated 2>/dev/null \
    | string replace -r '\s+' '\t'
end

# no file completions in mas
complete -c mas -f

### account
complete -c mas -n "__fish_use_subcommand" -f -a account -d "Prints the primary account Apple ID"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "account"
### help
complete -c mas -n "__fish_use_subcommand" -f -a help -d "Display general or command-specific help"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "help"
### home
complete -c mas -n "__fish_use_subcommand" -f -a home -d "Opens MAS Preview app page in a browser"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "home"
complete -c mas -n "__fish_seen_subcommand_from home info install open vendor" -xa "(__fish_mas_list_available)"
### info
complete -c mas -n "__fish_use_subcommand" -f -a info -d "Display app information from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "info"
### install
complete -c mas -n "__fish_use_subcommand" -f -a install -d "Install from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "install"
complete -c mas -n "__fish_seen_subcommand_from install lucky" -l force -d "Force reinstall"
### list
complete -c mas -n "__fish_use_subcommand" -f -a list -d "Lists apps from the Mac App Store which are currently installed"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "list"
### lucky
complete -c mas -n "__fish_use_subcommand" -f -a lucky -d "Install the first result from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "lucky"
### open
complete -c mas -n "__fish_use_subcommand" -f -a open -d "Opens app page in AppStore.app"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "open"
### outdated
complete -c mas -n "__fish_use_subcommand" -f -a outdated -d "Lists pending updates from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "outdated"
### reset
complete -c mas -n "__fish_use_subcommand" -f -a reset -d "Resets the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "reset"
complete -c mas -n "__fish_seen_subcommand_from reset" -l debug -d "Enable debug mode"
### search
complete -c mas -n "__fish_use_subcommand" -f -a search -d "Search for apps from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "search"
complete -c mas -n "__fish_seen_subcommand_from search" -l price -d "Show price of found apps"
### signin
complete -c mas -n "__fish_use_subcommand" -f -a signin -d "Sign in to the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "signin"
complete -c mas -n "__fish_seen_subcommand_from signin" -l dialog -d "Complete login with graphical dialog"
### signout
complete -c mas -n "__fish_use_subcommand" -f -a signout -d "Sign out of the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "signout"
### uninstall
complete -c mas -n "__fish_use_subcommand" -f -a uninstall -d "Uninstall app installed from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "uninstall"
complete -c mas -n "__fish_seen_subcommand_from uninstall" -l dry-run -d "Dry run mode"
complete -c mas -n "__fish_seen_subcommand_from uninstall" -x -a "(__fish_mas_list_installed)"
### upgrade
complete -c mas -n "__fish_use_subcommand" -f -a upgrade -d "Upgrade outdated apps from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "upgrade"
complete -c mas -n "__fish_seen_subcommand_from upgrade" -x -a "(__fish_mas_outdated_installed)"
### vendor
complete -c mas -n "__fish_use_subcommand" -f -a vendor -d "Opens vendor's app page in a browser"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "vendor"
### version
complete -c mas -n "__fish_use_subcommand" -f -a version -d "Print version number"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "version"
