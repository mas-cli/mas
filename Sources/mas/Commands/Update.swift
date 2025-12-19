//
// Update.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import StoreFoundation

extension MAS {
	/// Updates outdated apps installed from the App Store.
	struct Update: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Update outdated apps installed from the App Store",
			discussion: requiresRootPrivilegesMessage(),
			aliases: ["upgrade"]
		)

		@OptionGroup
		private var accurateOptionGroup: AccurateOptionGroup
		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var verboseOptionGroup: VerboseOptionGroup
		@OptionGroup
		private var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async throws {
			try await run(installedApps: try await nonTestFlightInstalledApps, lookupAppFromAppID: lookup(appID:))
		}

		private func run(
			installedApps: [InstalledApp],
			lookupAppFromAppID: (AppID) async throws -> CatalogApp
		) async throws {
			try await run(
				outdatedApps: forceOptionGroup.force // swiftformat:disable:next indent
				? installedApps.filter(for: optionalAppIDsOptionGroup.appIDs).map { ($0, "") }
				: await outdatedApps(
					installedApps: installedApps,
					lookupAppFromAppID: lookupAppFromAppID,
					accurateOptionGroup: accurateOptionGroup,
					verboseOptionGroup: verboseOptionGroup,
					optionalAppIDsOptionGroup: optionalAppIDsOptionGroup
				)
			)
		}

		private func run(outdatedApps: [OutdatedApp]) async throws {
			try await AppStore.update.apps(withADAMIDs: outdatedApps.map(\.installedApp.adamID))
		}
	}
}
