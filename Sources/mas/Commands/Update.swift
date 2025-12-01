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
	struct Update: OutdatedAppCommand {
		static let configuration = CommandConfiguration(
			abstract: "Update outdated apps installed from the App Store",
			discussion: requiresRootPrivilegesMessage(),
			aliases: ["upgrade"]
		)

		@OptionGroup
		var accurateOptionGroup: AccurateOptionGroup
		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		var verboseOptionGroup: VerboseOptionGroup
		@OptionGroup
		var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func outdatedApps(installedApps: [InstalledApp], appCatalog: some AppCatalog) async -> [OutdatedApp] {
			forceOptionGroup.force
			? installedApps.filter(by: optionalAppIDsOptionGroup).map { ($0, "") } // swiftformat:disable:this indent
			: await outdatedAppsDefault(installedApps: installedApps, appCatalog: appCatalog)
		}

		func process(_ outdatedApps: [OutdatedApp]) async throws {
			try await AppStore.update.apps(withADAMIDs: outdatedApps.map(\.installedApp.adamID))
		}
	}
}
