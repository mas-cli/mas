//
// Get.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Gets & installs free apps from the Mac App Store.
	struct Get: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Get & install free apps from the Mac App Store",
			aliases: ["purchase"]
		)

		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async throws {
			try await run(installedApps: try await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: some AppStoreSearcher) async throws {
			try await MAS.run { printer in
				let downloader = Downloader(printer: printer)
				for appID in requiredAppIDsOptionGroup.appIDs {
					do {
						try await downloader.downloadApp(
							withADAMID: try await appID.adamID(searcher: searcher),
							getting: true,
							installedApps: installedApps
						)
					} catch {
						printer.error(error: error)
					}
				}
			}
		}
	}
}
