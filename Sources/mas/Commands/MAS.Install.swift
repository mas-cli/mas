//
// MAS.Install.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs previously gotten apps from the App Store.
	struct Install: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Install previously gotten apps from the App Store",
			discussion: requiresRootPrivilegesMessage(),
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var catalogAppsOptionGroup: CatalogAppsOptionGroup
		@OptionGroup
		private var jobsOptionGroup: JobsOptionGroup

		func run() async {
			await AppStore.install.apps(
				withAppIDs: catalogAppsOptionGroup.appIDs,
				force: forceOptionGroup.force,
				maxConcurrentTaskCount: jobsOptionGroup.jobs,
			)
		}
	}
}
