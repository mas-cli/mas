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
			try await AppStore.get.apps(
				withAppIDs: requiredAppIDsOptionGroup.appIDs,
				force: forceOptionGroup.force,
				installedApps: try await installedApps,
				appCatalog: ITunesSearchAppCatalog()
			)
		}
	}
}
