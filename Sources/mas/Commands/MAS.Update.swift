//
// MAS.Update.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Updates outdated apps installed from the App Store.
	struct Update: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Update outdated apps installed from the App Store",
			discussion: requiresRootPrivilegesMessage(),
			aliases: ["upgrade"],
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var outdatedAppsOptionGroup: OutdatedAppsOptionGroup
		@OptionGroup
		private var jobsOptionGroup: JobsOptionGroup

		func run() async {
			await AppStore.update.apps(
				withADAMIDs: await outdatedAppsOptionGroup
					.outdatedApps(considerAllOutdated: forceOptionGroup.force, withFullJSON: false)
					.map(\.installedApp.adamID),
				maxConcurrentTaskCount: jobsOptionGroup.jobs,
			)
		}
	}
}
