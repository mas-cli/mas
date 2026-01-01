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
			aliases: ["upgrade"],
		)

		@OptionGroup
		private var accurateOptionGroup: AccurateOptionGroup
		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var verboseOptionGroup: VerboseOptionGroup
		@OptionGroup
		private var installedAppIDsOptionGroup: InstalledAppIDsOptionGroup

		func run() async throws {
			try await run(installedApps: try await installedApps.filter(!\.isTestFlight), lookupAppFromAppID: lookup(appID:))
		}

		private func run(installedApps: [InstalledApp], lookupAppFromAppID: (AppID) async throws -> CatalogApp)
		async throws { // swiftformat:disable:this indent
			try await run(
				outdatedApps: forceOptionGroup.force // swiftformat:disable:next indent
				? installedApps.filter(for: installedAppIDsOptionGroup.appIDs).map { ($0, "") }
				: await outdatedApps(
					installedApps: installedApps,
					lookupAppFromAppID: lookupAppFromAppID,
					accurateOptionGroup: accurateOptionGroup,
					verboseOptionGroup: verboseOptionGroup,
					installedAppIDsOptionGroup: installedAppIDsOptionGroup,
				),
			)
		}

		private func run(outdatedApps: [OutdatedApp]) async throws {
			try await AppStore.update.apps(withADAMIDs: outdatedApps.map(\.installedApp.adamID))
		}
	}
}
