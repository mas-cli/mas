//
// Home.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Opens Mac App Store app pages in the default web browser.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Home: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Open Mac App Store app pages in the default web browser"
		)

		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async {
			await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: some AppStoreSearcher) async {
			await run(searchResults: await requiredAppIDsOptionGroup.appIDs.lookupResults(from: searcher))
		}

		func run(searchResults: [SearchResult]) async {
			await run(appStorePageURLs: searchResults.map(\.appStorePageURL))
		}

		func run(appStorePageURLs: [String]) async {
			await appStorePageURLs.forEach(attemptTo: "open") { appStorePageURL in
				guard let url = URL(string: appStorePageURL) else {
					throw MASError.urlParsing(appStorePageURL)
				}

				try await url.open()
			}
		}
	}
}
