//
// Install.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs previously gotten apps from the App Store.
	struct Install: InstallAppCommand {
		static let configuration = CommandConfiguration(
			abstract: "Install previously gotten apps from the App Store",
			discussion: requiresRootPrivilegesMessage()
		)

		@OptionGroup
		var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		var appStoreAction: AppStoreAction {
			AppStore.install
		}
	}
}
