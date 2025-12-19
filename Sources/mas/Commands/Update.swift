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
			try await run(installedApps: try await nonTestFlightInstalledApps, appCatalog: ITunesSearchAppCatalog())
		}

		private func run(installedApps: [InstalledApp], appCatalog: some AppCatalog) async throws {
			try await run(
				outdatedApps: forceOptionGroup.force
				? installedApps.filter(by: optionalAppIDsOptionGroup).map { ($0, "") } // swiftformat:disable:this indent
				: await outdatedApps(
					installedApps: installedApps,
					appCatalog: appCatalog,
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
