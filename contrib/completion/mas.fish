# fish completions for mas

function __fish_mas_list_available -d "Lists applications available to install from the Mac App Store"
    set query (commandline -ct)
    if set results (command mas search "$query" 2>/dev/null)
        for res in $results
            echo "$res"
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
complete -c mas -n "__fish_use_subcommand" -f -a account -d "Display the Apple Account signed in to the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "account"
### config
complete -c mas -n "__fish_use_subcommand" -f -a config -d "Display mas config & related system info"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "config"
complete -c mas -n "__fish_seen_subcommand_from config" -l markdown -d "Output as Markdown"
### help
complete -c mas -n "__fish_use_subcommand" -f -a help -d "Display general or command-specific help"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "help"
### home
complete -c mas -n "__fish_use_subcommand" -f -a home -d "Open app's Mac App Store web page in the default web browser"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "home"
complete -c mas -n "__fish_seen_subcommand_from home info install open purchase vendor" -xa "(__fish_mas_list_available)"
### info
complete -c mas -n "__fish_use_subcommand" -f -a info -d "Display app information from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "info"
### install
complete -c mas -n "__fish_use_subcommand" -f -a install -d "Install previously purchased app(s) from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "install"
complete -c mas -n "__fish_seen_subcommand_from install lucky" -l force -d "Force reinstall"
### list
complete -c mas -n "__fish_use_subcommand" -f -a list -d "List apps installed from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "list"
### lucky
complete -c mas -n "__fish_use_subcommand" -f -a lucky -d "Install the first app returned from searching the Mac App Store (app must have been previously purchased)"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "lucky"
### open
complete -c mas -n "__fish_use_subcommand" -f -a open -d "Open app page in 'App Store.app'"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "open"
### outdated
complete -c mas -n "__fish_use_subcommand" -f -a outdated -d "List pending app updates from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "outdated"
complete -c mas -n "__fish_seen_subcommand_from outdated" -l verbose -d "Display warnings about apps unknown to the Mac App Store"
### purchase
complete -c mas -n "__fish_use_subcommand" -f -a purchase -d "\"Purchase\" and install free apps from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "purchase"
### region
complete -c mas -n "__fish_use_subcommand" -f -a region -d "Display the region of the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "region"
### reset
complete -c mas -n "__fish_use_subcommand" -f -a reset -d "Reset Mac App Store running processes"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "reset"
complete -c mas -n "__fish_seen_subcommand_from reset" -l debug -d "Output debug information"
### search
complete -c mas -n "__fish_use_subcommand" -f -a search -d "Search for apps from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "search"
complete -c mas -n "__fish_seen_subcommand_from search" -l price -d "Display the price of each app"
### signin
complete -c mas -n "__fish_use_subcommand" -f -a signin -d "Sign in to an Apple Account in the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "signin"
complete -c mas -n "__fish_seen_subcommand_from signin" -l dialog -d "Provide password via graphical dialog"
### signout
complete -c mas -n "__fish_use_subcommand" -f -a signout -d "Sign out of the Apple Account currently signed in to the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "signout"
### uninstall
complete -c mas -n "__fish_use_subcommand" -f -a uninstall -d "Uninstall app installed from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "uninstall"
complete -c mas -n "__fish_seen_subcommand_from uninstall" -l dry-run -d "Perform dry run"
complete -c mas -n "__fish_seen_subcommand_from uninstall" -x -a "(__fish_mas_list_installed)"
### upgrade
complete -c mas -n "__fish_use_subcommand" -f -a upgrade -d "Upgrade outdated app(s) from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "upgrade"
complete -c mas -n "__fish_seen_subcommand_from upgrade" -x -a "(__fish_mas_outdated_installed)"
### vendor
complete -c mas -n "__fish_use_subcommand" -f -a vendor -d "Open vendor's app web page in the default web browser"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "vendor"
### version
complete -c mas -n "__fish_use_subcommand" -f -a version -d "Display version number"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "version"
