//
// Seller.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Opens apps' seller pages in the default web browser.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Seller: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Open apps' seller pages in the default web browser",
			aliases: ["vendor"]
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
			await run(
				sellerURLs: searchResults.compactMap { searchResult in
					guard let sellerURL = searchResult.sellerURL else {
						MAS.printer.error("No seller website available for", searchResult.adamID)
						return nil
					}

					return sellerURL
				}
			)
		}

		func run(sellerURLs: [String]) async {
			await sellerURLs.forEach(attemptTo: "open") { sellerURL in
				guard let url = URL(string: sellerURL) else {
					throw MASError.urlParsing(sellerURL)
				}

				try await url.open()
			}
		}
	}
}
