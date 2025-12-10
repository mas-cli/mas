//
// Get.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Gets & installs free apps from the App Store.
	struct Get: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Get & install free apps from the App Store",
			discussion: requiresRootPrivilegesMessage(),
			aliases: ["purchase"]
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
			try await AppStore.get.apps(withADAMIDs: adamIDs, force: forceOptionGroup.force, installedApps: installedApps)
		}
	}
}
