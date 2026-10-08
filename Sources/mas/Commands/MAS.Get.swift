//
// MAS.Get.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Gets & installs free apps from the App Store.
	struct Get: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Get & install free apps from the App Store",
			discussion: requiresRootPrivilegesMessage(),
			aliases: ["purchase"],
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var catalogAppsOptionGroup: CatalogAppsOptionGroup
		@OptionGroup
		private var jobsOptionGroup: JobsOptionGroup

		func run() async {
			await AppStore.get.apps(
				withAppIDs: catalogAppsOptionGroup.appIDs,
				force: forceOptionGroup.force,
				maxConcurrentTaskCount: jobsOptionGroup.jobs,
			)
		}
	}
}
