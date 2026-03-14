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
			run(installedApps: try await installedApps)
		}

		func run(installedApps: [InstalledApp]) {
			let installedApps = installedApps.filter(for: installedAppIDsOptionGroup.appIDs)
			guard !installedApps.isEmpty else {
				printer.warning(
					"""
					No installed apps found

					If this is unexpected, any of the following command lines should fix things by reindexing apps in Spotlight\
					 (which might take some time):

					# Individual apps (if you know exactly what apps were incorrectly omitted):
					mdimport /Applications/Example.app

					# All apps (<LargeAppVolume> is the volume optionally selected for large apps):
					mdimport /Applications /Volumes/<LargeAppVolume>/Applications

					# All file system volumes (if neither aforementioned command solved the issue):
					sudo mdutil -Eai on
					""",
				)
				return
			}

			outputFormatOptionGroup.info(installedApps.map(String.init(describing:)).joined(separator: "\n"))
		}
	}
}
