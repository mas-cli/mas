//
// Lucky.swift
// mas
//
// Copyright © 2017 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs the first app returned from searching the Mac App Store (app must
	/// have been previously purchased).
	///
	/// Uses the iTunes Search API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Lucky: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: """
				Install the first app returned from searching the Mac App Store
				(app must have been previously purchased)
				"""
		)

		@OptionGroup
		var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		var searchTermOptionGroup: SearchTermOptionGroup

		/// Runs the command.
		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			try await mas.run { printer in
				try await run(downloader: Downloader(printer: printer), installedApps: installedApps, searcher: searcher)
			}
		}

		private func run(downloader: Downloader, installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			let searchTerm = searchTermOptionGroup.searchTerm
			let results = try await searcher.search(for: searchTerm)
			guard let result = results.first else {
				throw MASError.noSearchResultsFound(for: searchTerm)
			}
			try await install(appID: result.trackId, installedApps: installedApps, downloader: downloader)
		}

		/// Installs an app.
		///
		/// - Parameters:
		///   - appID: App ID.
		///   - installedApps: List of installed apps.
		///   - downloader: `Downloader`.
		/// - Throws: Any error that occurs while attempting to install the app.
		private func install(appID: AppID, installedApps: [InstalledApp], downloader: Downloader) async throws {
			if let installedApp = installedApps.first(where: { $0.id == appID }), !forceOptionGroup.force {
				downloader.printer.warning("Already installed:", installedApp.idAndName)
			} else {
				try await downloader.downloadApp(withAppID: appID)
			}
		}
	}
}
