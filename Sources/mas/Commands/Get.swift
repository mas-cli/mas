//
// Get.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Gets & installs free apps from the App Store.
	struct Get: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Get & install free apps from the App Store",
			discussion: requiresRootPrivilegesMessage(),
			aliases: ["purchase"],
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var catalogAppIDsOptionGroup: CatalogAppIDsOptionGroup

		func run() async throws {
			try await AppStore.get.apps(
				withAppIDs: catalogAppIDsOptionGroup.appIDs,
				force: forceOptionGroup.force,
				installedApps: try await installedApps,
				lookupAppFromAppID: lookup(appID:),
			)
		}
	}
}
