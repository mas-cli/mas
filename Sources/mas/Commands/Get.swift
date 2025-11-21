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
			aliases: ["purchase"]
		)

		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async {
			do {
				await run(installedApps: try await installedApps, appCatalog: ITunesSearchAppCatalog())
			} catch {
				printer.error(error: error)
			}
		}

		func run(installedApps: [InstalledApp], appCatalog: some AppCatalog) async {
			await run(installedApps: installedApps, adamIDs: await requiredAppIDsOptionGroup.appIDs.adamIDs(from: appCatalog))
		}

		func run(installedApps: [InstalledApp], adamIDs: [ADAMID]) async {
			await adamIDs.forEach(attemptTo: "get app for ADAM ID") { adamID in
				try await downloadApp(withADAMID: adamID, getting: true, installedApps: installedApps)
			}
		}
	}
}
