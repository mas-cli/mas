//
// Purchase.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// "Purchases" & installs free apps from the Mac App Store.
	struct Purchase: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "\"Purchase\" & install free apps from the Mac App Store"
		)

		@OptionGroup
		var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: some AppStoreSearcher) async throws {
			try await MAS.run { printer in
				let downloader = Downloader(printer: printer)
				for appID in requiredAppIDsOptionGroup.appIDs {
					do {
						try await downloader.downloadApp(
							withADAMID: try await appID.adamID(searcher: searcher),
							purchasing: true,
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
