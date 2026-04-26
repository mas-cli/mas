function __fish_mas_list_available -d 'Lists applications available from the App Store'
	set query (commandline -ct)
	if test -n "$query"; and set results (command mas search "$query" 2>/dev/null)
		for res in $results
			echo "$res"
		end | string trim --left | string replace -r '\s+' '\t'
	end
end

function __fish_mas_list_installed -d 'Lists installed applications from the App Store'
	command mas list 2>/dev/null | string trim --left | string replace -r '\s+' '\t'
end

function __fish_mas_outdated_installed -d 'Lists outdated installed applications from the App Store'
	command mas outdated 2>/dev/null | string trim --left | string replace -r '\s+' '\t'
end

complete -c mas -f

complete -c mas -n __fish_use_subcommand -fa config -d 'Output mas config & related system info'
complete -c mas -n __fish_use_subcommand -fa get -d 'Get & install free apps from the App Store'
complete -c mas -n __fish_use_subcommand -fa help -d 'Output general or command-specific help'
complete -c mas -n __fish_use_subcommand -fa home -d 'Open App Store app pages in the default web browser'
complete -c mas -n __fish_use_subcommand -fa install -d 'Install previously gotten apps from the App Store'
complete -c mas -n __fish_use_subcommand -fa list -d 'List apps installed from the App Store'
complete -c mas -n __fish_use_subcommand -fa lookup -d 'Output app info from the App Store'
complete -c mas -n __fish_use_subcommand -fa lucky -d 'Install the first app returned from searching the App Store'
complete -c mas -n __fish_use_subcommand -fa open -d 'Open app page in \'App Store.app\''
complete -c mas -n __fish_use_subcommand -fa outdated -d 'List pending app updates from the App Store'
complete -c mas -n __fish_use_subcommand -fa reset -d 'Reset App Store processes & clear cached App Store downloads'
complete -c mas -n __fish_use_subcommand -fa search -d 'Search for apps in the App Store'
complete -c mas -n __fish_use_subcommand -fa seller -d 'Open apps\' seller pages in the default web browser'
complete -c mas -n __fish_use_subcommand -fa signout -d 'Sign out of the App Store'
complete -c mas -n __fish_use_subcommand -fa uninstall -d 'Uninstall apps installed from the App Store'
complete -c mas -n __fish_use_subcommand -fa update -d 'Update outdated apps installed from the App Store'
complete -c mas -n __fish_use_subcommand -fa version -d 'Output version number'

complete -c mas -n '__fish_seen_subcommand_from config info list lookup outdated search; and not __fish_contains_opt json' -l json -d 'Output JSON' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from get home info install lookup open purchase seller vendor' -xa '(__fish_mas_list_available)' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from get home info install list lookup open outdated purchase seller uninstall update upgrade vendor; and not __fish_contains_opt bundle' -l bundle -d 'Process all app IDs as bundle IDs' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from get install lucky purchase update upgrade; and not __fish_contains_opt force' -l force -d 'Force reinstall' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from help' -xa 'config get help home install list lookup lucky open outdated reset search seller signout uninstall update version' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from list outdated uninstall' -xa '(__fish_mas_list_installed)'
complete -c mas -n '__fish_seen_subcommand_from outdated update upgrade; and not __fish_contains_opt accurate; and not __fish_contains_opt inaccurate' -l accurate -d 'Accurate, slower outdated app detection' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from outdated update upgrade; and not __fish_contains_opt accurate; and not __fish_contains_opt inaccurate' -l inaccurate -d 'Inaccurate, faster outdated app detection' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from outdated update upgrade; and not __fish_contains_opt check-min-os; and not __fish_contains_opt no-check-min-os' -l check-min-os -d 'Check if macOS can install latest app version' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from outdated update upgrade; and not __fish_contains_opt check-min-os; and not __fish_contains_opt no-check-min-os' -l no-check-min-os -d 'Do not check if macOS can install latest app version' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from outdated update upgrade; and not __fish_contains_opt verbose' -l verbose -d 'Warn about app IDs unknown to the App Store' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from search; and not __fish_contains_opt price' -l price -d 'Output the price of each app' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from uninstall; and not __fish_contains_opt all' -l all -d 'Uninstall all App Store apps' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from uninstall; and not __fish_contains_opt dry-run' -l dry-run -d 'Perform dry run' # editorconfig-checker-disable-line
complete -c mas -n '__fish_seen_subcommand_from update upgrade' -xa '(__fish_mas_outdated_installed)'
