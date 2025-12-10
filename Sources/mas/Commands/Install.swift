//
// Install.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs previously gotten apps from the App Store.
	struct Install: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Install previously gotten apps from the App Store",
			discussion: requiresRootPrivilegesMessage()
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async throws {
			try await run(installedApps: try await installedApps, appCatalog: ITunesSearchAppCatalog())
		}

		private func run(installedApps: [InstalledApp], appCatalog: some AppCatalog) async throws {
			try await run(
				installedApps: installedApps,
				adamIDs: await requiredAppIDsOptionGroup.appIDs.lookupCatalogApps(from: appCatalog).map(\.adamID)
			)
		}

		private func run(installedApps: [InstalledApp], adamIDs: [ADAMID]) async throws {
			try await AppStore.install.apps(withADAMIDs: adamIDs, force: forceOptionGroup.force, installedApps: installedApps)
		}
	}
}
