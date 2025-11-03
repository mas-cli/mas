//
// List.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Lists all apps installed from the Mac App Store.
	struct List: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "List all apps installed from the Mac App Store"
		)

		@OptionGroup
		var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async throws {
			try run(installedApps: try await installedApps)
		}

		func run(installedApps: [InstalledApp]) throws {
			try MAS.run { run(printer: $0, installedApps: installedApps) }
		}

		private func run(printer: Printer, installedApps: [InstalledApp]) {
			let installedApps = installedApps.filter(by: optionalAppIDsOptionGroup, printer: printer)
			guard !installedApps.isEmpty else {
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
			guard
				let maxADAMIDLength = installedApps.map({ String(describing: $0.adamID).count }).max(),
				let maxAppNameLength = installedApps.map(\.name.count).max()
			else {
				return
			}

			let format = "%\(maxADAMIDLength)lu  %@  (%@)"
			printer.info(
				installedApps.map { installedApp in
					String(
						format: format,
						installedApp.adamID,
						installedApp.name.padding(toLength: maxAppNameLength, withPad: " ", startingAt: 0),
						installedApp.version
					)
				}
				.joined(separator: "\n")
			)
		}
	}
}
