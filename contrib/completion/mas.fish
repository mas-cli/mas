function __fish_mas_list_available -d "Lists applications available to install from the App Store"
	set query (commandline -ct)
	if set results (command mas search "$query" 2>/dev/null)
		for res in $results
			echo "$res"
		end | string trim --left | string replace -r '\s+' '\t'
	end
end

function __fish_mas_list_installed -d "Lists installed applications from the App Store"
	command mas list 2>/dev/null | string trim --left | string replace -r '\s+' '\t'
end

function __fish_mas_outdated_installed -d "Lists outdated installed applications from the App Store"
	command mas outdated 2>/dev/null | string trim --left | string replace -r '\s+' '\t'
end

complete -c mas -f

complete -c mas -n "__fish_use_subcommand" -f -a config -d "Output mas config & related system info"
complete -c mas -n "__fish_use_subcommand" -f -a get -d "Get & install free apps from the App Store"
complete -c mas -n "__fish_use_subcommand" -f -a help -d "Output general or command-specific help"
complete -c mas -n "__fish_use_subcommand" -f -a home -d "Open App Store app pages in the default web browser"
complete -c mas -n "__fish_use_subcommand" -f -a install -d "Install previously gotten apps from the App Store"
complete -c mas -n "__fish_use_subcommand" -f -a list -d "List all apps installed from the App Store"
complete -c mas -n "__fish_use_subcommand" -f -a lookup -d "Output app information from the App Store"
complete -c mas -n "__fish_use_subcommand" -f -a lucky -d "Install the first app returned from searching the App Store"
complete -c mas -n "__fish_use_subcommand" -f -a open -d "Open app page in 'App Store.app'"
complete -c mas -n "__fish_use_subcommand" -f -a outdated -d "List pending app updates from the App Store"
complete -c mas -n "__fish_use_subcommand" -f -a reset -d "Reset App Store processes & clear cached App Store downloads"
complete -c mas -n "__fish_use_subcommand" -f -a search -d "Search for apps in the App Store"
complete -c mas -n "__fish_use_subcommand" -f -a seller -d "Open apps' seller pages in the default web browser"
complete -c mas -n "__fish_use_subcommand" -f -a signout -d "Sign out of the Apple Account currently signed in to the App Store" # editorconfig-checker-disable-line
complete -c mas -n "__fish_use_subcommand" -f -a uninstall -d "Uninstall apps installed from the App Store"
complete -c mas -n "__fish_use_subcommand" -f -a update -d "Update outdated apps installed from the App Store"
complete -c mas -n "__fish_use_subcommand" -f -a version -d "Output version number"

complete -c mas -n "__fish_seen_subcommand_from get home install lookup open seller" -xa "(__fish_mas_list_available)"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "config"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "get"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "help"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "home"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "install"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "list"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "lookup"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "lucky"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "open"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "outdated"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "reset"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "search"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "seller"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "signout"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "uninstall"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "update"
complete -c mas -n "__fish_seen_subcommand_from help" -xa "version"
complete -c mas -n "__fish_seen_subcommand_from install lucky" -l force -d "Force reinstall"
complete -c mas -n "__fish_seen_subcommand_from outdated" -l verbose -d "Output warnings about app IDs unknown to the App Store" # editorconfig-checker-disable-line
complete -c mas -n "__fish_seen_subcommand_from search" -l price -d "Output the price of each app"
complete -c mas -n "__fish_seen_subcommand_from uninstall" -l dry-run -d "Perform dry run"
complete -c mas -n "__fish_seen_subcommand_from uninstall" -x -a "(__fish_mas_list_installed)"
complete -c mas -n "__fish_seen_subcommand_from update" -x -a "(__fish_mas_outdated_installed)"
