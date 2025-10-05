//
// Outdated.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import StoreFoundation

extension MAS {
	/// Outputs a list of installed apps which have updates available to be
	/// installed from the Mac App Store.
	struct Outdated: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "List pending app updates from the Mac App Store"
		)

		@OptionGroup
		var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async throws {
			try await run(installedApps: await installedApps)
		}

		func run(installedApps: [InstalledApp]) async throws {
			try await MAS.run { await run(downloader: Downloader(printer: $0), installedApps: installedApps) }
		}

		private func run(downloader: Downloader, installedApps: [InstalledApp]) async {
			for installedApp in installedApps.filter(by: optionalAppIDsOptionGroup, printer: downloader.printer) {
				do {
					try await downloader.downloadApp(withADAMID: installedApp.adamID) { download, shouldOutput in
						if shouldOutput, let metadata = download.metadata, installedApp.version != metadata.bundleVersion {
							downloader.printer.info(
								installedApp.adamID,
								" ",
								installedApp.name,
								" (",
								installedApp.version,
								" -> ",
								metadata.bundleVersion ?? "unknown",
								")",
								separator: ""
							)
						}
						return true
					}
				} catch {
					downloader.printer.error(error: error)
				}
			}
		}
	}
}
