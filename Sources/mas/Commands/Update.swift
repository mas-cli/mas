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
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var outdatedAppOptionGroup: OutdatedAppOptionGroup

		func run() async throws {
			try await run(installedApps: try await installedApps().filter(!\.isTestFlight))
		}

		private func run(installedApps: [InstalledApp]) async throws {
			try await run(
				outdatedApps: forceOptionGroup.force // swiftformat:disable:next indent
				? installedApps.filter(for: outdatedAppOptionGroup.installedAppIDsOptionGroup.appIDs)
					.map { OutdatedApp(installedApp: $0, newVersion: "") } // swiftformat:disable:this indent
				: await outdatedAppOptionGroup.outdatedApps(from: installedApps),
			)
		}

		private func run(outdatedApps: [OutdatedApp]) async throws {
			try await AppStore.update.apps(withADAMIDs: outdatedApps.map(\.installedApp.adamID))
		}
	}
}
