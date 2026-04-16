//
// Update.swift
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
		private var outdatedAppOptionGroup: OutdatedAppOptionGroup
		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var verboseOptionGroup: VerboseOptionGroup
		@OptionGroup
		private var installedAppIDsOptionGroup: InstalledAppIDsOptionGroup

		func run() async throws {
			try await run(installedApps: try await installedApps.filter(!\.isTestFlight))
		}

		private func run(installedApps: [InstalledApp]) async throws {
			try await run(
				outdatedApps: forceOptionGroup.force // swiftformat:disable:next indent
				? installedApps.filter(for: installedAppIDsOptionGroup.appIDs).map { ($0, "") }
				: await installedApps.outdatedApps(
					filterFor: installedAppIDsOptionGroup.appIDs,
					accuracy: outdatedAppOptionGroup.accuracy,
					shouldCheckMinimumOSVersion: outdatedAppOptionGroup.shouldCheckMinimumOSVersion,
					shouldWarnIfUnknownApp: verboseOptionGroup.verbose,
				),
			)
		}

		private func run(outdatedApps: [OutdatedApp]) async throws {
			try await AppStore.update.apps(withADAMIDs: outdatedApps.map(\.installedApp.adamID))
		}
	}
}
