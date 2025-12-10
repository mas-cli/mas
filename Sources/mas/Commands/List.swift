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
	struct List: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "List all apps installed from the App Store"
		)

		@OptionGroup
		private var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async throws {
			run(installedApps: try await installedApps)
		}

		func run(installedApps: [InstalledApp]) {
			let installedApps = installedApps.filter(by: optionalAppIDsOptionGroup)
			guard
				let maxADAMIDLength = installedApps.map({ String(describing: $0.adamID).count }).max(),
				let maxNameLength = installedApps.map(\.name.count).max()
			else {
				printer.warning(
					"""
					No installed apps found

					If this is unexpected, the following command line should fix it by
					(re)creating the Spotlight index (which might take some time):

					sudo mdutil -Eai on
					"""
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
						installedApp.version
					)
				}
				.joined(separator: "\n")
			)
		}
	}
}
