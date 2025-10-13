//
// Upgrade.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import StoreFoundation

extension MAS {
	/// Upgrades outdated apps installed from the Mac App Store.
	struct Upgrade: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Upgrade outdated apps installed from the Mac App Store"
		)

		@OptionGroup
		var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async throws {
			try await run(installedApps: try await installedApps)
		}

		func run(installedApps: [InstalledApp]) async throws {
			try await MAS.run { await run(downloader: Downloader(printer: $0), installedApps: installedApps) }
		}

		private func run(downloader: Downloader, installedApps: [InstalledApp]) async {
			for installedApp in installedApps.filter(by: optionalAppIDsOptionGroup, printer: downloader.printer) {
				do {
					try await downloader.downloadApp(withADAMID: installedApp.adamID) { download, _ in
						installedApp.version == download.metadata?.bundleVersion
					}
				} catch {
					downloader.printer.error(error: error)
				}
			}
		}
	}
}
