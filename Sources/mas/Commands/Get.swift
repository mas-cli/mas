//
// Get.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Gets & installs free apps from the App Store.
	struct Get: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Get & install free apps from the App Store",
			discussion: requiresRootPrivilegesMessage,
			aliases: ["purchase"]
		)

		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async {
			do {
				try requireRootUserAndWheelGroup(withErrorMessageSuffix: "to get apps")
				try await ProcessInfo.processInfo.runAsSudoEffectiveUserAndSudoEffectiveGroup {
					await run(installedApps: try await installedApps, appCatalog: ITunesSearchAppCatalog())
				}
			} catch {
				printer.error(error: error)
			}
		}

		private func run(installedApps: [InstalledApp], appCatalog: some AppCatalog) async {
			await run(installedApps: installedApps, adamIDs: await requiredAppIDsOptionGroup.appIDs.adamIDs(from: appCatalog))
		}

		private func run(installedApps: [InstalledApp], adamIDs: [ADAMID]) async {
			await adamIDs.forEach(attemptTo: "get app for ADAM ID") { adamID in
				try await downloadApp(withADAMID: adamID, getting: true, installedApps: installedApps)
			}
		}
	}
}
