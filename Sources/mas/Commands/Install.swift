//
// Install.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs previously gotten apps from the Mac App Store.
	struct Install: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Install previously gotten apps from the Mac App Store"
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
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
							forceDownload: forceOptionGroup.force,
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
