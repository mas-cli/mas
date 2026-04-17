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
		private var installedAppIDsOptionGroup: InstalledAppIDsOptionGroup

		func run() async throws {
			run(installedApps: try await installedApps)
		}

		func run(installedApps: [InstalledApp]) {
			let installedApps = installedApps.filter(for: installedAppIDsOptionGroup.appIDs)
			guard
				let maxADAMIDLength = installedApps.map({ String(describing: $0.adamID).count }).max(),
				let maxNameLength = installedApps.map(\.name.count).max()
			else {
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

			let format = "%\(maxADAMIDLength)lu  %@  (%@)"
			printer.info(
				installedApps.map { installedApp in
					String(
						format: format,
						installedApp.adamID,
						installedApp.name.padding(toLength: maxNameLength, withPad: " ", startingAt: 0),
						installedApp.version,
					)
				}
				.joined(separator: "\n"),
			)
		}
	}
}
