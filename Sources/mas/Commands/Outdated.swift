//
// Outdated.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Outputs a list of installed apps which have updates available to be
	/// installed from the App Store.
	struct Outdated: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "List pending app updates from the App Store"
		)

		@OptionGroup
		private var accurateOptionGroup: AccurateOptionGroup
		@OptionGroup
		private var verboseOptionGroup: VerboseOptionGroup
		@OptionGroup
		private var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async throws {
			await run(installedApps: try await installedApps.filter(!\.isTestFlight), lookupAppFromAppID: lookup(appID:))
		}

		private func run(installedApps: [InstalledApp], lookupAppFromAppID: (AppID) async throws -> CatalogApp) async {
			run(
				outdatedApps: await outdatedApps(
					installedApps: installedApps,
					lookupAppFromAppID: lookupAppFromAppID,
					accurateOptionGroup: accurateOptionGroup,
					verboseOptionGroup: verboseOptionGroup,
					optionalAppIDsOptionGroup: optionalAppIDsOptionGroup
				)
			)
		}

		private func run(outdatedApps: [OutdatedApp]) {
			guard
				let maxADAMIDLength = outdatedApps.map({ String(describing: $0.installedApp.adamID).count }).max(),
				let maxNameLength = outdatedApps.map(\.installedApp.name.count).max(),
				let maxVersionLength = outdatedApps.map(\.installedApp.version.count).max()
			else {
				return
			}

			let format = "%\(maxADAMIDLength)lu  %@  (%@ -> %@)"
			MAS.printer.info(
				outdatedApps.map { installedApp, newVersion in
					String(
						format: format,
						installedApp.adamID,
						installedApp.name.padding(toLength: maxNameLength, withPad: " ", startingAt: 0),
						installedApp.version.padding(toLength: maxVersionLength, withPad: " ", startingAt: 0),
						newVersion
					)
				}
				.joined(separator: "\n")
			)
		}
	}
}
