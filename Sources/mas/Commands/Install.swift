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
			discussion: requiresRootPrivilegesMessage(),
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var catalogAppIDsOptionGroup: CatalogAppIDsOptionGroup

		func run() async throws {
			try await AppStore.install.apps(
				withAppIDs: catalogAppIDsOptionGroup.appIDs,
				force: forceOptionGroup.force,
				installedApps: try await installedApps,
				lookupAppFromAppID: lookup(appID:),
			)
		}
	}
}
