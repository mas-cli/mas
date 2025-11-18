//
// Update.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import StoreFoundation

extension MAS {
	/// Updates outdated apps installed from the Mac App Store.
	struct Update: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Update outdated apps installed from the Mac App Store",
			aliases: ["upgrade"]
		)

		@OptionGroup
		private var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async {
			do {
				await run(installedApps: try await nonTestFlightInstalledApps)
			} catch {
				printer.error(error: error)
			}
		}

		func run(installedApps: [InstalledApp]) async {
			for installedApp in installedApps.filter(by: optionalAppIDsOptionGroup) {
				do {
					try await downloadApp(withADAMID: installedApp.adamID) { download, _ in
						installedApp.version == download.metadata?.bundleVersion
					}
				} catch {
					printer.error(error: error)
				}
			}
		}
	}
}
