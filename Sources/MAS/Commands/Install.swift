//
// Install.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs previously purchased apps from the Mac App Store.
	struct Install: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Install previously purchased apps from the Mac App Store"
		)

		@OptionGroup
		var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		var appIDsOptionGroup: AppIDsOptionGroup

		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			try await MAS.run { printer in
				await Downloader(printer: printer).downloadApps(
					withAppIDs: appIDsOptionGroup.appIDs,
					purchasing: false,
					forceDownload: forceOptionGroup.force,
					installedApps: installedApps,
					searcher: searcher
				)
			}
		}
	}
}
