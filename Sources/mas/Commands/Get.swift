//
// Get.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Gets & installs free apps from the App Store.
	struct Get: InstallAppCommand {
		static let configuration = CommandConfiguration(
			abstract: "Get & install free apps from the App Store",
			discussion: requiresRootPrivilegesMessage(),
			aliases: ["purchase"]
		)

		@OptionGroup
		var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		var appStoreAction: AppStoreAction {
			AppStore.get
		}
	}
}
