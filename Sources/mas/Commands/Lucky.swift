//
// Lucky.swift
// mas
//
// Copyright © 2017 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs the first app returned from searching the Mac App Store (app must
	/// have been previously gotten).
	///
	/// Uses the iTunes Search API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Lucky: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Install the first app returned from searching the Mac App Store",
			discussion: "App will install only if it has already been gotten"
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var searchTermOptionGroup: SearchTermOptionGroup

		func run() async throws {
			try await run(installedApps: try await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: some AppStoreSearcher) async throws {
			try await MAS.run { printer in
				let downloader = Downloader(printer: printer)
				let searchTerm = searchTermOptionGroup.searchTerm
				guard let adamID = try await searcher.search(for: searchTerm).first?.adamID else {
					throw MASError.noSearchResultsFound(for: searchTerm)
				}

				try await downloader.downloadApp(
					withADAMID: adamID,
					forceDownload: forceOptionGroup.force,
					installedApps: installedApps
				)
			}
		}
	}
}
