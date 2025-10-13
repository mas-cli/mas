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
			abstract: "Install the first app returned from searching the Mac App Store",
			discussion: "App will install only if it has already been purchased"
		)

		@OptionGroup
		var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		var searchTermOptionGroup: SearchTermOptionGroup

		func run() async throws {
			try await run(installedApps: try await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: some AppStoreSearcher) async throws {
			try await MAS.run { printer in
				try await run(downloader: Downloader(printer: printer), installedApps: installedApps, searcher: searcher)
			}
		}

		private func run(
			downloader: Downloader,
			installedApps: [InstalledApp],
			searcher: some AppStoreSearcher
		) async throws {
			let searchTerm = searchTermOptionGroup.searchTerm
			guard let adamID = try await searcher.search(for: searchTerm).first?.adamID else {
				throw MASError.noSearchResultsFound(for: searchTerm)
			}

			if !forceOptionGroup.force, let installedApp = installedApps.first(where: { $0.adamID == adamID }) {
				downloader.printer.warning(
					"Already installed: ",
					installedApp.name,
					" (search term ",
					searchTerm,
					")",
					separator: ""
				)
				return
			}

			try await downloader.downloadApp(withADAMID: adamID)
		}
	}
}
