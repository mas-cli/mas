//
// Install.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Installs previously gotten apps from the App Store.
	struct Install: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Install previously gotten apps from the App Store",
			discussion: requiresRootPrivilegesMessage
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async {
			do {
				try await run(installedApps: try await installedApps, appCatalog: ITunesSearchAppCatalog())
			} catch {
				printer.error(error: error)
			}
		}

		private func run(installedApps: [InstalledApp], appCatalog: some AppCatalog) async throws {
			try await run(
				installedApps: installedApps,
				adamIDs: await requiredAppIDsOptionGroup.appIDs.adamIDs(from: appCatalog)
			)
		}

		private func run(installedApps: [InstalledApp], adamIDs: [ADAMID]) async throws {
			try requireRootUserAndWheelGroup(withErrorMessageSuffix: "to install apps")
			try await ProcessInfo.processInfo.runAsSudoEffectiveUserAndSudoEffectiveGroup {
				await adamIDs.forEach(attemptTo: "install app for ADAM ID") { adamID in
					try await downloadApp(withADAMID: adamID, forceDownload: forceOptionGroup.force, installedApps: installedApps)
				}
			}
		}
	}
}
