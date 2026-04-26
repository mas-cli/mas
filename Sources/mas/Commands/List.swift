//
// List.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Lists all apps installed from the App Store.
	struct List: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "List apps installed from the App Store",
		)

		@OptionGroup
		private var outputFormatOptionGroup: OutputFormatOptionGroup
		@OptionGroup
		private var installedAppIDsOptionGroup: InstalledAppIDsOptionGroup

		func run() async throws {
			run(installedApps: try await installedApps(withFullJSON: outputFormatOptionGroup.shouldOutputJSON))
		}

		func run(installedApps: [InstalledApp]) {
			let installedApps = installedApps.filter(for: installedAppIDsOptionGroup.appIDs)
			guard !installedApps.isEmpty else {
				printer.warning( // editorconfig-checker-disable
					"""
					No installed apps found

					If this is unexpected, index apps in Spotlight (which might take some time):

					# Individual app (if the omitted apps are known). e.g., for Xcode:
					mdimport /Applications/Xcode.app

					# All apps:
					vol="$(/usr/libexec/PlistBuddy -c "Print :PreferredVolume:name" ~/Library/Preferences/com.apple.appstored.plist 2>/dev/null)"
					mdimport /Applications ${vol:+"/Volumes/${vol}/Applications"}

					# All volumes:
					sudo mdutil -Eai on
					""", // editorconfig-checker-enable
				)
				return
			}

			outputFormatOptionGroup.info(installedApps.map(String.init(describing:)).joined(separator: "\n"))
		}
	}
}
