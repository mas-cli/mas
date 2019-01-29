# fish completions for mas

### account
complete -c mas -n "__fish_use_subcommand" -f -a account -d "Prints the primary account Apple ID"
### help
complete -c mas -n "__fish_use_subcommand" -f -a help -d "Display general or command-specific help"
### home
complete -c mas -n "__fish_use_subcommand" -f -a home -d "Opens MAS Preview app page in a browser"
### info
complete -c mas -n "__fish_use_subcommand" -f -a info -d "Display app information from the Mac App Store"
### install
complete -c mas -n "__fish_use_subcommand" -f -a install -d "Install from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from install" -l force -d "Force reinstall"
### list
complete -c mas -n "__fish_use_subcommand" -f -a list -d "Lists apps from the Mac App Store which are currently installed"
### lucky
complete -c mas -n "__fish_use_subcommand" -f -a lucky -d "Install the first result from the Mac App Store"
### open
complete -c mas -n "__fish_use_subcommand" -f -a open -d "Opens app page in AppStore.app"
### outdated
complete -c mas -n "__fish_use_subcommand" -f -a outdated -d "Lists pending updates from the Mac App Store"
### reset
complete -c mas -n "__fish_use_subcommand" -f -a reset -d "Resets the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from reset" -l debug -d "Enable debug mode"
### search
complete -c mas -n "__fish_use_subcommand" -f -a search -d "Search for apps from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from search" -l price -d "Show price of found apps"
### signin
complete -c mas -n "__fish_use_subcommand" -f -a signin -d "Sign in to the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from signin" -l price -d "Complete login with graphical dialog"
### signout
complete -c mas -n "__fish_use_subcommand" -f -a signout -d "Sign out of the Mac App Store"
### uninstall
complete -c mas -n "__fish_use_subcommand" -f -a uninstall -d "Uninstall app installed from the Mac App Store"
complete -c mas -n "__fish_seen_subcommand_from uninstall" -l dry-run -d "Dry run mode"
for line in (command mas list 2>/dev/null)
    set app (string split " " -- $line)
    complete -c mas -n "__fish_seen_subcommand_from uninstall" -f -a $app[1] -d $app[2]
end
### upgrade
complete -c mas -n "__fish_use_subcommand" -f -a upgrade -d "Upgrade outdated apps from the Mac App Store"
### vendor
complete -c mas -n "__fish_use_subcommand" -f -a vendor -d "Opens vendor's app page in a browser"
### version
complete -c mas -n "__fish_use_subcommand" -f -a version -d "Print version number"
