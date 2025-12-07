//
// Update.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import StoreFoundation

extension MAS {
	/// Updates outdated apps installed from the App Store.
	struct Update: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Update outdated apps installed from the App Store",
			discussion: requiresRootPrivilegesMessage,
			aliases: ["upgrade"]
		)

		@OptionGroup
		private var accurateOptionGroup: AccurateOptionGroup
		@OptionGroup
		private var verboseOptionGroup: VerboseOptionGroup
		@OptionGroup
		private var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async {
			do {
				try requireRootUserAndWheelGroup(withErrorMessageSuffix: "to update apps")
				try await accurateOptionGroup.run(
					accurate: { shouldIgnoreUnknownApps in
						await accurate(
							installedApps: try await nonTestFlightInstalledApps,
							appCatalog: ITunesSearchAppCatalog(),
							shouldIgnoreUnknownApps: shouldIgnoreUnknownApps
						)
					},
					inaccurate: {
						await inaccurate(installedApps: try await nonTestFlightInstalledApps, appCatalog: ITunesSearchAppCatalog())
					}
				)
			} catch {
				printer.error(error: error)
			}
		}

		private func accurate(
			installedApps: [InstalledApp],
			appCatalog: some AppCatalog,
			shouldIgnoreUnknownApps: Bool
		) async {
			for installedApp in
				await installedApps
				.filter(by: optionalAppIDsOptionGroup) // swiftformat:disable:this indent
				.filter(if: shouldIgnoreUnknownApps, appCatalog: appCatalog, shouldWarnIfAppUnknown: verboseOptionGroup.verbose)
			{ // swiftformat:disable:previous indent
				do {
					try await downloadApp(withADAMID: installedApp.adamID) { download, _ in
						installedApp.version == download.metadata?.bundleVersion
					}
				} catch {
					printer.error(error: error)
				}
			}
		}

		private func inaccurate(installedApps: [InstalledApp], appCatalog: some AppCatalog) async {
			for adamID in
				await installedApps
				.filter(by: optionalAppIDsOptionGroup) // swiftformat:disable indent
				.outdated(appCatalog: appCatalog, shouldWarnIfAppUnknown: verboseOptionGroup.verbose)
				.map(\.installedApp.adamID)
			{ // swiftformat:enable indent
				do {
					try await downloadApp(withADAMID: adamID)
				} catch {
					printer.error(error: error)
				}
			}
		}
	}
}
